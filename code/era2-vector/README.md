# Era 2 — Vector Fortran (Cray-1, 1976)

Same source as Era 1 plus a vectorization directive. On a Cray-1, CFT emits chained vector instructions. On a modern compiler with `-O3 -march=native`, you get AVX-512 / NEON / SVE — the same idea, three thousand times faster.

## Build and run

```bash
gfortran -O3 -march=native -fopt-info-vec saxpy.f90 -o saxpy_vec
./saxpy_vec
```

You should see "loop vectorized" in the build output. Compare runtime to Era 1.

## C version

`saxpy_vec.c` is the C equivalent. `clang -O3 -march=native -Rpass=loop-vectorize saxpy_vec.c` will report the vectorization width achieved.

## What changed from Era 1

Source code: identical loop body. Compiler flags: enabled vectorization. Output binary: completely different — one vector instruction per 4–8 iterations on AVX-512, or per 2–4 on NEON.

This is the central lesson of the Cray-1 era and it has not changed: well-written sequential code, plus a vectorizing compiler, is most of the way to peak performance. The compiler engineers earn their salaries.
