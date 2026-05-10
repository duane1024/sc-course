# Era 3 — OpenMP (Cray Y-MP, 1988 → multi-core CPUs, 2005+)

Add `#pragma omp parallel for simd` and you get the two-level parallelism the Y-MP shipped: distribute iterations across CPU cores, vectorize within each core's slice. Direct lineage from `CMIC$ DOALL ... VECTOR`.

## Build and run

```bash
clang -O3 -march=native -fopenmp saxpy_omp.c -o saxpy_omp
OMP_NUM_THREADS=8 ./saxpy_omp
```

Compare timings with `OMP_NUM_THREADS=1, 2, 4, 8`.

## What you should see

Throughput should scale roughly linearly until you hit memory bandwidth saturation, then flatten. SAXPY is memory-bound — once you're at ~150–200 GB/s on a modern laptop, additional threads don't help.
