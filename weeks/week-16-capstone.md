# Week 16 — Capstone: SAXPY Across the Eras

## The exercise

The same computational kernel — `y = a*x + y`, on vectors of one million double-precision floats — implemented in the idiom of every architectural era we've covered. You write the implementations, run them on your laptop where possible (and on Colab where a GPU is required), measure performance, count lines of code, and write a final essay reflecting on what each abstraction reveals and hides.

The scaffold is in `labs/16-capstone/`. We provide reference implementations; your job is to read them carefully, run them, modify them, and *understand* them.

## The six eras

### Era 1 — CDC 6600, scalar Fortran (1964)

```fortran
      SUBROUTINE SAXPY(N, A, X, Y)
      INTEGER N
      DOUBLE PRECISION A, X(N), Y(N)
      INTEGER I
      DO 10 I = 1, N
        Y(I) = A * X(I) + Y(I)
   10 CONTINUE
      RETURN
      END
```

What's happening: a sequential loop, one iteration at a time. On the 6600, the scoreboard found instruction-level parallelism between the multiply (issued to the multiplier unit) and the add (issued to the adder unit) of consecutive iterations. The programmer wrote sequential code; the hardware found the parallelism.

Modern relevance: this loop, compiled with `gfortran -O3`, gets auto-vectorized and produces nearly identical machine code to the Era 2 hand-vectorized version below. The 1964 compiler couldn't do that. The 2026 compiler can.

### Era 2 — Cray-1, vector Fortran (1976)

```fortran
      SUBROUTINE SAXPY(N, A, X, Y)
      INTEGER N
      DOUBLE PRECISION A, X(N), Y(N)
*       Compiler will vectorize this loop into 64-element strip-mines.
*       No source change needed - the loop is dependence-free.
!DIR$ IVDEP
      DO 10 I = 1, N
        Y(I) = A * X(I) + Y(I)
   10 CONTINUE
      RETURN
      END
```

The source is the same (!) — but the compiler is now expected to emit chained vector multiply-add instructions, with a strip-mine wrapper for `N mod 64`. The `!DIR$ IVDEP` directive is the programmer's promise that the loop is free of carried dependencies, allowing the compiler to vectorize without trying to prove it.

Lab task: compile this (or its modern equivalent in C) with `clang -O3 -march=native -Rpass=loop-vectorize` and observe that the modern compiler does what CFT did in 1978.

### Era 3 — Cray Y-MP, microtasking + vector (1988)

```fortran
      SUBROUTINE SAXPY(N, A, X, Y)
      INTEGER N
      DOUBLE PRECISION A, X(N), Y(N)
CMIC$ DOALL SHARED(A, X, Y, N) PRIVATE(I) VECTOR
      DO 10 I = 1, N
        Y(I) = A * X(I) + Y(I)
   10 CONTINUE
      RETURN
      END
```

Modern equivalent in C with OpenMP:

```c
void saxpy(int n, double a, const double *x, double *y) {
    #pragma omp parallel for simd
    for (int i = 0; i < n; i++)
        y[i] = a * x[i] + y[i];
}
```

The microtasking directive splits the loop's iterations across the Y-MP's 8 CPUs; each CPU's chunk is then vectorized for a 64-element vector register. Two-level parallelism, source-level annotation. The OpenMP version on a modern multi-core CPU does the *exact* same thing: parallelize across cores, vectorize within each core's chunk.

### Era 4 — Distributed memory, MPI (1994)

```c
#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    MPI_Init(&argc, &argv);
    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    long N = 1L << 24;
    long local_n = N / size;
    double a = 2.0;
    double *x = malloc(local_n * sizeof(double));
    double *y = malloc(local_n * sizeof(double));
    for (long i = 0; i < local_n; i++) { x[i] = i; y[i] = 1.0; }

    /* No communication needed — element-wise, no neighbors. */
    for (long i = 0; i < local_n; i++)
        y[i] = a * x[i] + y[i];

    /* Reduce to verify */
    double local_sum = 0;
    for (long i = 0; i < local_n; i++) local_sum += y[i];
    double global_sum;
    MPI_Reduce(&local_sum, &global_sum, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);
    if (rank == 0) printf("global sum = %g\n", global_sum);

    free(x); free(y);
    MPI_Finalize();
    return 0;
}
```

SAXPY is "embarrassingly parallel" — no communication needed during the kernel. The MPI complexity here is mostly *boilerplate* (init/finalize, ranks, allocation by rank). The reduction at the end is the only place ranks talk to each other. *Real* applications spend most of their MPI complexity on halo exchanges and collectives that SAXPY doesn't need; we kept this minimal so the code stays readable.

Run it: `mpirun -n 4 ./saxpy_mpi`.

### Era 5 — GPU, CUDA / HIP (2007)

```c
#include <stdio.h>
__global__ void saxpy(int n, double a, const double *x, double *y) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) y[i] = a * x[i] + y[i];
}

int main(void) {
    int N = 1<<20;
    double *x, *y;
    cudaMallocManaged(&x, N*sizeof(double));
    cudaMallocManaged(&y, N*sizeof(double));
    for (int i = 0; i < N; i++) { x[i] = i; y[i] = 1.0; }

    int block = 256;
    int grid = (N + block - 1) / block;
    saxpy<<<grid, block>>>(N, 2.0, x, y);
    cudaDeviceSynchronize();

    cudaFree(x); cudaFree(y);
    return 0;
}
```

The kernel is per-thread. The runtime grids 1,048,576 threads, organizes them into warps of 32, and schedules them onto the GPU's streaming multiprocessors. Each warp executes one 32-wide SIMD instruction at a time — making this, beneath the abstraction, *the same vector instruction the Cray-1 issued for SAXPY in 1976*, just much wider and at a higher clock with vastly more memory bandwidth.

The HIP equivalent is character-identical except for `cuda` → `hip` namespace renames.

### Era 6 — 2025 Modern C++ with Standard Parallelism

```cpp
#include <execution>
#include <vector>
#include <numeric>
#include <iostream>

int main() {
    long N = 1L << 24;
    std::vector<double> x(N), y(N, 1.0);
    std::iota(x.begin(), x.end(), 0.0);
    double a = 2.0;

    std::transform(std::execution::par_unseq,
                   x.begin(), x.end(), y.begin(), y.begin(),
                   [a](double xi, double yi) { return a*xi + yi; });

    double sum = std::reduce(std::execution::par_unseq,
                             y.begin(), y.end(), 0.0);
    std::cout << "sum = " << sum << "\n";
}
```

`std::execution::par_unseq` tells the implementation: "you may parallelize *and* vectorize *and* reorder the work". Compiled with NVHPC's `nvc++ -stdpar=gpu`, this **runs on a GPU** — the standard library implementation generates CUDA kernels under the hood. With stock g++ or clang, behavior depends on the standard-library implementation and how it was built; some configurations vectorize, some use a CPU thread pool through a backend such as oneTBB, and some effectively run serial. The same source can target multiple backends, but the guarantee is semantic permission, not a portable performance promise.

Equivalent in Fortran 2018:

```fortran
program saxpy
  implicit none
  integer, parameter :: N = 2**24
  real(8) :: x(N), y(N), a
  integer :: i
  a = 2.0d0
  do concurrent (i = 1:N)
    x(i) = real(i, 8)
    y(i) = 1.0d0
  end do
  do concurrent (i = 1:N)
    y(i) = a * x(i) + y(i)
  end do
  print *, sum(y)
end program
```

Compiled with NVHPC's `nvfortran -stdpar=gpu`, again, runs on a GPU.

This is the *most direct* lineage of the 1976 vector Fortran source: the *programmer's* code is barely longer than the Era 2 version, the compiler is doing all the parallelization and vectorization and offloading. Cray-style "write a vector-friendly loop and let the compiler handle the rest" — taken to its logical 50-year conclusion.

## What you measure

For each era's implementation, on a problem size of `N = 2^24`:

| Era | LOC | Single-thread time | Best-config time | Speedup vs Era 1 |
|---|---|---|---|---|
| 1. Scalar Fortran | ~5 | (baseline) | (same) | 1× |
| 2. Vector (auto) | ~5 + dir | (same compile) | (auto-vec) | 4–8× |
| 3. OpenMP | ~7 | — | × cores × vec | 30–60× |
| 4. MPI | ~25 | — | × ranks | similar to OMP |
| 5. CUDA | ~20 | — | × GPU SMs | 100–500× |
| 6. par_unseq | ~10 | — | × GPU SMs | 100–500× (with nvc++) |

(Your numbers will vary considerably with hardware. The qualitative pattern won't.)

## What you write

A 1,500–2,500 word essay with these sections:

1. **What did each abstraction make easy?** Pick one operation that's clearer in each idiom (e.g., MPI made distributed-memory boundaries explicit; SIMT made per-thread reasoning natural; standard parallelism made offloading transparent).
2. **What did each abstraction hide?** Pick one bug or performance pathology each idiom is prone to (e.g., MPI deadlocks when send/recv don't pair; CUDA branch divergence; standard parallelism's opaque cost model).
3. **The ratio of source effort to peak performance** has gone in a U-shape: Era 1 was minimal effort but minimal performance. Era 4 (MPI) was maximum effort. Era 6 is approaching minimal effort *and* near-peak performance, but only if the compiler is good. What does this say about where compiler R&D should focus next?
4. **Your final argument**: is the modern supercomputer the *successor* of the Cray-1 (a continuous lineage of "one fast machine, generalized"), or is it a *different kind of object* that happens to share the name? Defend your answer with at least three architectural specifics from the course.

## Submission

If you're auditing this course online, no one will grade you. The point of the essay is to make the synthesis explicit to yourself. If you want feedback, post your essay as a discussion in the course repo's GitHub Discussions, link your code, and the maintainers (and other students) will respond.

## The contested definition of "supercomputer"

In 1976, the word was unambiguous: a supercomputer was the machine at LANL. Singular, identifiable, paid for by the federal government, FORTRAN-programmed, FP64. The question "is *that* a supercomputer?" did not arise.

In 2026 the word is genuinely contested, and the answer depends on what you measure:

- **By HPL FP64 Rmax**: the Top500 list. El Capitan, Frontier, Aurora, JUPITER, Fugaku, Eagle (Microsoft), LUMI, Leonardo, MareNostrum 5, Tuolumne. A 30-PFLOPS floor for the top 10. This is the *traditional* definition.
- **By delivered FP16 throughput**: hyperscaler AI-training clusters. Microsoft Eagle (publicly listed), Meta Research SuperCluster, xAI Colossus (~100,000+ H100s), the Anthropic and OpenAI training pods, Google TPU v5p and v6 superpods. Most of these exceed exascale in FP16 but do not submit HPL and are not on Top500.
- **By novelty of substrate**: Cerebras CS-3 wafer-scale (one chip, 900,000 cores, exascale-class on specific workloads). Tenstorrent Grayskull. Groq LPU. Graphcore Bow. None resemble a traditional supercomputer; some out-perform the Top500 on the workloads they were designed for.
- **By organizational shape**: shared, programmable, FP64-capable, scientific-infrastructure-shaped, run as multi-tenant capacity by a national lab or university consortium. This is the *practitioner's* working definition. Microsoft Eagle qualifies (it submits HPL, accepts external workloads under contract); xAI Colossus does not, even though Colossus is plausibly bigger.

These definitions are diverging fast. The pre-2020 consensus that "the Top500 measures the world's most powerful computers" no longer holds — the list now measures the world's most powerful computers *that submit to a particular benchmark, at a particular precision, under a particular organizational form*. AI-training clusters built by single companies are plausibly bigger; they are not run as scientific infrastructure and they do not submit.

When you write the final essay, this is a *real* question to take a position on: what should "supercomputer" mean in 2026? Defend a definition with at least three architectural specifics from the course, and explain which currently-existing machines your definition includes and excludes. There is no wrong answer here — but there are weak ones, and the weakest ones avoid the question.

## Going further: capstone variants

SAXPY-across-eras is the minimum-viable capstone — it isolates the *programming-model* dimension while keeping the kernel trivial. If you want a stronger project, swap in a more interesting kernel and keep the cross-era framing. Some directions that work:

- **Sparse matrix-vector multiply** on a matrix from the [SuiteSparse Matrix Collection](https://sparse.tamu.edu). The kernel is *irregular*, so the abstractions that hid SAXPY's costs cleanly are forced to confront gather/scatter, load imbalance, and (on MPI) communication patterns that aren't pure halo exchange.
- **3D 7-point stencil** with a domain that spans multiple nodes. Closer to real climate / CFD codes; the MPI version has actual halo exchange (revisit Lab 9); the GPU version exercises shared-memory tiling.
- **Climate mini-app**, specifically [`miniWeather`](https://github.com/mrnorman/miniWeather) — explicitly designed as an HPC training proxy. Has reference implementations in MPI, OpenMP, OpenACC, CUDA, and Kokkos; doing a comparative Roofline analysis across these is paper-quality work.
- **Dense `dgemm`** comparing naïve, blocked, threaded, and tuned-BLAS implementations. The point is that one library call (Week 7's lesson) hides four decades of vector and parallel optimization.

Each of these gives you the same cross-era structure as the canonical capstone with more analytical surface area. See `assessment.md` for the full project portfolio and reproducibility expectations.

## What comes next

This course covered the past sixty years. The next decade — from now through ~2035 — is being shaped by:

- **AI training as the dominant high-end workload.** AI-specialized chips (Cerebras, Groq, Tenstorrent, custom hyperscaler silicon like TPU and Trainium) are starting to compete with traditional HPC accelerators. Frontier and El Capitan are dual-use: weapons simulation *and* AI training.
- **Disaggregated memory.** CXL is permitting memory pools shared across servers. The "what is a node" question is becoming harder.
- **Photonic interconnects.** Co-packaged optics, ribbon-fiber inside chips. The bandwidth-distance trade-off shifts.
- **Quantum + classical hybrid systems.** A coprocessor model — a quantum chip handed problems by a classical supercomputer. Not because anyone has solved a useful problem on a current quantum machine, but because the systems integration work has to start somewhere.
- **Energy-bounded scaling.** Few public HPC sites can allocate 100 MW to a single machine. A 5 EFLOPS machine in 2030 must be much more efficient than today's if it is to fit normal facility budgets. This is currently a research problem with no clear solution.

You now have the historical foundation to read each of these as they unfold and tell whether they're new ideas, recurring ideas, or recurring ideas with a new name.

Cray died in 1996. The architecture he built has been continuously rebuilt, redirected, and renewed by people he never met, on machines he would not have recognized, doing work he made possible. That's not a unique pattern in computing history — but he was unusually clear-eyed about what mattered. We've spent fifteen weeks taking him seriously.

Good luck.
