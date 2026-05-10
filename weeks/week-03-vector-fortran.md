# Week 3 — Vector Fortran and the Birth of Vectorization

## Where we are in 2026

When you write a `for` loop and the compiler emits AVX-512 or NEON or SVE instructions, every concept it uses to decide what's safe to vectorize — dependency analysis, alias analysis, loop interchange, strip-mining, scalar expansion, idiom recognition — was developed in the late 1970s and early 1980s for one purpose: getting Fortran to run fast on a Cray. The toolkit hasn't really changed. The targets have.

This week we look at the programming model, what the compiler had to do, and what you, the programmer, had to do when the compiler couldn't.

## CFT: the compiler that made the Cray-1 a product

The Cray-1's hardware was a marvel, but for it to *sell* the compiler had to be excellent. The first Cray-1 shipped without a vectorizing compiler at all — Los Alamos got a scalar Fortran compiler and Cray's promise that vectorization was coming. CFT — Cray Fortran Translator — arrived shortly after and was the first production-quality auto-vectorizer in the world.

CFT operated on stock Fortran-66 and Fortran-77 source. The contract was: write your loops as you always have, and we will turn them into vector instructions where it's safe. "Where it's safe" was the work. Consider:

```fortran
      DO 10 I = 2, N
        A(I) = A(I-1) + B(I)
   10 CONTINUE
```

This loop has a **read-after-write dependency** through `A`: iteration `I` reads what iteration `I-1` wrote. If you turn it into a vector instruction, all 64 elements are read at once, before any writes from previous iterations have happened. The result is wrong. CFT had to *not* vectorize this loop, despite it being structurally identical to:

```fortran
      DO 10 I = 1, N
        A(I) = B(I) + C(I)
   10 CONTINUE
```

which is perfectly safe.

The dependency analysis required to make this distinction — figuring out when `A(I-1)` and `A(I)` alias, when they're independent, when they alias only sometimes — is what's now called **iteration-space dependency testing**. The classical algorithms (GCD test, Banerjee test, Omega test) were developed by David Kuck's group at Illinois (Parafrase, KAP) and Randy Allen and Ken Kennedy at Rice during the late 1970s and 1980s, *specifically* to make CFT and competing vectorizing Fortran compilers smarter. Every modern C/C++ compiler's loop optimizer is a direct descendant.

## The compiler-programmer collaboration

Auto-vectorization in the 1970s was, and remains today, **conservative**. When in doubt, the compiler must produce scalar code. So the Cray-Fortran ecosystem grew a vocabulary of programmer-supplied promises:

```fortran
!DIR$ IVDEP
      DO 10 I = 1, N
        A(I) = A(K(I)) + B(I)
   10 CONTINUE
```

`IVDEP` — Ignore Vector Dependencies — tells the compiler "I, the programmer, promise no element of `A(K(I))` overlaps with `A(I)` for the iteration range I care about. Vectorize this loop." If you lie, the answer is silently wrong. Modern OpenMP `#pragma omp simd` is the same idea.

Other directives in the era:

- `!DIR$ VECTOR ALWAYS` — force vectorization even if cost model thinks it's a loss.
- `!DIR$ NOVECTOR` — don't even try.
- `!DIR$ SHORTLOOP` — promise the trip count fits in a single vector register, skip the strip-mine wrapper.

Every one of these has a 2026 equivalent in the GCC, Clang, Intel ICX, NVHPC, and Cray (now HPE) compilers.

## Loop transformations: the seven big moves

CFT and its descendants relied on a small set of source-level transformations to expose vectorization. You should recognize all of these because they're still in use:

### Loop interchange

```fortran
      DO 10 J = 1, N        DO 10 I = 1, N
        DO 20 I = 1, N    →   DO 20 J = 1, N
          A(I,J) = ...          A(I,J) = ...
   20   CONTINUE         20   CONTINUE
   10 CONTINUE           10 CONTINUE
```

In Fortran, `A(I,J)` is column-major: `I` is the fast-varying index. If your inner loop runs over `J`, you stride across columns and your vector loads have stride `N` rather than 1. Interchange the loops, and stride-1 access lights up the memory subsystem.

This is exactly the same transformation a 2026 compiler does to convert `for(i){ for(j){ A[i][j] }}` into row-major-friendly form for AVX, and the same transformation NVIDIA's `nvcc` does to coalesce global memory accesses on a GPU. Different machine, same problem: feed the vector unit at peak bandwidth.

### Strip-mining

```fortran
*       Original:
      DO 10 I = 1, N
        Y(I) = A * X(I) + Y(I)
   10 CONTINUE

*       Strip-mined for vector length 64:
      DO 20 II = 1, N, 64
        ILEN = MIN(64, N - II + 1)
        ! Inner 'loop' is one vector instruction sequence of length ILEN
        DO 30 I = II, II + ILEN - 1
          Y(I) = A * X(I) + Y(I)
   30   CONTINUE
   20 CONTINUE
```

You don't write strip-mining yourself in Fortran — the compiler does. But conceptually this is what every vector compiler must do for any loop trip count that isn't statically the vector length. AVX-512 vectorizers do this; CUDA does it implicitly via thread block sizing.

### Loop distribution / fission

If a loop has both vectorizable and non-vectorizable parts, split it into two loops. The vectorizable one runs at full speed; the other stays scalar:

```fortran
*       Mixed:
      DO 10 I = 1, N
        A(I) = B(I) + C(I)            ! vectorizable
        IF (A(I) .LT. 0) STOP 'BAD'   ! not vectorizable
   10 CONTINUE

*       After fission:
      DO 20 I = 1, N
        A(I) = B(I) + C(I)
   20 CONTINUE
      DO 30 I = 1, N
        IF (A(I) .LT. 0) STOP 'BAD'
   30 CONTINUE
```

### Scalar expansion

Eliminate a loop-carried dependency on a scalar by promoting it to a temporary array:

```fortran
      DO 10 I = 1, N           DO 10 I = 1, N
        T = X(I)*X(I) + 1   →    T(I) = X(I)*X(I) + 1
        Y(I) = T*A             Y(I) = T(I)*A
   10 CONTINUE                10 CONTINUE
```

The first loop has every iteration writing `T`, which a naïve dependency analyzer flags. The second has each iteration writing a different element. Auto-vectorizers do this implicitly today by recognizing that `T` is dead between iterations.

### Vectorizable reductions

```fortran
      S = 0.0
      DO 10 I = 1, N
        S = S + X(I)*Y(I)
   10 CONTINUE
```

Loop-carried dependency on `S` — but the operation is associative (well, almost — floating-point addition is not strictly associative; you accept the rounding difference for performance). The compiler issues parallel partial sums in vector registers and reduces at the end. This is the exact same reduction every modern parallel framework supports.

## A worked example: 5-point stencil

A 2D Laplacian update:

```fortran
      DO 20 J = 2, N-1
        DO 10 I = 2, M-1
          B(I,J) = 0.25 * (A(I-1,J) + A(I+1,J) + A(I,J-1) + A(I,J+1))
   10   CONTINUE
   20 CONTINUE
```

The inner loop is over `I`, the fast-varying index — good, stride-1. There are no loop-carried dependencies in `I` (every `B(I,J)` is independent of every other; the read of `A` looks at a previous column `J-1` but never at `B`). CFT vectorizes the inner loop trivially. Strip-mined to vector length 64, the inner loop becomes:

- Load 64 elements of `A(I-1,J)` (vector load, stride 1, slightly offset)
- Load 64 elements of `A(I+1,J)` (vector load, stride 1, slightly offset the other way)
- Load 64 elements of `A(I,J-1)` (one column back, stride 1)
- Load 64 elements of `A(I,J+1)` (one column forward, stride 1)
- Vector add, vector add, vector add (chained)
- Vector multiply by 0.25 (chained — actually fused in via FMA-equivalent on later Crays)
- Vector store

A dozen instructions per 64 grid points. This kernel was the standard demo of vector machines, and it's still the standard demo of every SIMD ISA today.

## Lab — Compiler vectorization on a modern laptop

Even though we don't have a Cray-1, every modern compiler is essentially a souped-up CFT. In `labs/03-vectorize/` we work through six small loops in C — some easy to vectorize, some hard, some impossible — and read the compiler's vectorization report:

```bash
clang -O3 -Rpass=loop-vectorize -Rpass-missed=loop-vectorize \
      -Rpass-analysis=loop-vectorize loops.c -c
```

You'll see the compiler succeeding, failing, and asking for help. The point: the conversation between programmer and compiler that started in 1976 has not ended. You're on the same side of it.

## Discussion questions

1. The `IVDEP` directive lets the programmer override the compiler's dependency analysis. What's the equivalent in modern C? In modern C++? In Fortran 2008? Why have multiple equivalents emerged rather than one converging on a standard?
2. CFT was conservative: when in doubt, generate scalar code. Modern auto-vectorizers are also conservative, but for *different* reasons (alias analysis through pointers, runtime trip counts, function calls inside loops). Pick one of those reasons and explain why it would not have applied to a Cray-1 Fortran program.
3. Strip-mining produces a clean-up tail for the last `N mod VL` elements. On the Cray-1, this was scalar. On AVX-512, it can be a masked vector instruction. What does the existence of *masked* vector instructions tell you about the architectural tradeoff between Cray-style fixed-length vectors and modern variable-length vectors (ARM SVE, RISC-V V)?

## Further reading

- Allen, J.R. & Kennedy, K. (1987). "Automatic translation of FORTRAN programs to vector form". *ACM TOPLAS*. The canonical paper on what CFT-class compilers do.
- Padua, D.A. & Wolfe, M.J. (1986). "Advanced compiler optimizations for supercomputers". *CACM*. Wolfe later wrote the textbook *High Performance Compilers for Parallel Computing*; both are essential.
- Cray Research, *CFT Reference Manual*, publication SR-0009. On bitsavers.
- Modern counterpart: Maleki, Saeed et al. (2011). "An evaluation of vectorizing compilers". *PACT*. Comparison of GCC, ICC, IBM XL on a 151-loop benchmark suite — sobering reading.
