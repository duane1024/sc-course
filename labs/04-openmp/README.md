# Lab 04 — OpenMP as Cray Microtasking

5-point stencil three ways: serial, OpenMP, OpenMP+SIMD.

## Build and run

```bash
clang -O3 -march=native -fopenmp stencil.c -o stencil
OMP_NUM_THREADS=8 ./stencil 4096 100
```

Args: grid side N, timesteps T.

## What to observe

1. Without `-fopenmp`, the loop is serial and AVX-vectorized.
2. With OpenMP and 8 threads, you should see a 6–7× speedup until you hit memory-bandwidth saturation.
3. The Cray Y-MP equivalent would have used `CMIC$ DOALL ... VECTOR` — the source structure is identical.
