# Era 5 — CUDA / SIMT (NVIDIA G80+, 2007)

Per-thread programming model. Source code shows what one thread does for one element; runtime aggregates threads into warps and executes them SIMD-style.

## Build and run

```bash
nvcc -O3 saxpy.cu -o saxpy
./saxpy
```

For AMD GPUs:

```bash
hipify-perl saxpy.cu > saxpy.hip.cpp
hipcc -O3 saxpy.hip.cpp -o saxpy
./saxpy
```

(The HIP source is character-for-character identical to CUDA except for namespace renames.)

## What you should see

On modern hardware, near-peak memory bandwidth — 80–95% of the GPU's theoretical HBM bandwidth. SAXPY is the textbook bandwidth-bound kernel.

## What's interesting

The CUDA kernel is `y[i] = a * x[i] + y[i]` — exactly what was in Era 1. Surrounding it: index calculation from `(blockIdx, threadIdx)`, allocation via `cudaMallocManaged`, kernel launch syntax `<<<grid, block>>>`. The kernel itself is the same arithmetic that ran on a CDC 6600 in 1964. The infrastructure for getting a million parallel copies of it onto the metal is what changed.
