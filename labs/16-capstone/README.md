# Lab 16 — Capstone: SAXPY across six eras

The same kernel, six implementations, six different programming models. See `code/` at the repo root for the per-era reference implementations:

- `code/era1-scalar/`     — scalar Fortran (CDC 6600 era)
- `code/era2-vector/`     — vector Fortran (Cray-1 era), with C-with-pragmas as the modern equivalent
- `code/era3-openmp/`     — OpenMP (Cray Y-MP / multi-core era)
- `code/era4-mpi/`        — MPI (T3E / Beowulf / cluster era)
- `code/era5-cuda/`       — CUDA (modern accelerator)
- `code/era6-stdpar/`     — modern C++ with `std::execution::par_unseq` and Fortran `do concurrent`

## Run them

Each era directory has a `README.md` with the exact compile command for that implementation. Most build with stock Linux/macOS toolchains. The CUDA and stdpar GPU paths require either:
- An NVIDIA GPU and CUDA Toolkit (or NVHPC for stdpar GPU offload), or
- Google Colab with a T4/A100 runtime, adapting the commands from the relevant era README.

## What to do

1. Build and run all six implementations on the same machine.
2. Time each on `N = 2^24`. Record:
   - Lines of code (count the kernel logic, not boilerplate).
   - Wall-clock time.
   - Achieved memory bandwidth (3 × N × 8 bytes / time).
3. Plot LOC vs. throughput. Note the U-shape: Era 1 minimal LOC, mediocre perf; Era 4 (MPI) maximum LOC; Era 6 (`par_unseq`) approaching minimal LOC and near-peak perf.
4. Write the capstone essay described in Week 16.

## Reference numbers

Indicative for a Macbook Pro M3 (Apple Silicon, 12 perf cores, 200 GB/s memory bandwidth) and an NVIDIA RTX 4070 (~500 GB/s, ~30 TFLOPS FP32):

| Era | Time @ N=2^24 | Throughput |
|---|---|---|
| 1. Scalar Fortran | ~80 ms | 2.5 GB/s |
| 2. Vectorized C | ~10 ms | 20 GB/s |
| 3. OpenMP+SIMD | ~1 ms | 200 GB/s (saturates DRAM) |
| 4. MPI -n 8 | ~1 ms + 0.5 ms init | similar |
| 5. CUDA on RTX 4070 | ~0.7 ms | ~470 GB/s |
| 6. nvc++ -stdpar=gpu | ~0.7 ms | ~470 GB/s |

Within a factor of 2 of these is "expected".
