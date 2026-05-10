# Lab 13 — CUDA SAXPY (or Metal / ROCm / Colab)

The same SAXPY implemented for whichever GPU stack you have available.

## If you have NVIDIA hardware

```bash
nvcc -O3 saxpy.cu -o saxpy
./saxpy
```

Profile:

```bash
nsys profile --stats=true ./saxpy
ncu --set full ./saxpy
```

## If you have an AMD GPU and ROCm

```bash
hipify-perl saxpy.cu > saxpy.hip.cpp
hipcc -O3 saxpy.hip.cpp -o saxpy
./saxpy
```

## If you have Apple Silicon

Use the provided Metal version:

```bash
swiftc -O saxpy_metal.swift -framework Metal -o saxpy_metal
./saxpy_metal
```

Or use the MLX version:

```bash
python3 -m pip install mlx
python3 saxpy_mlx.py
```

The Apple examples use `float32`, because that is the practical fast path on Apple GPUs. Compare bandwidth trends rather than bit-for-bit agreement with the CUDA `double` example.

## If you have neither

Open `saxpy_colab.ipynb` in Google Colab. Choose Runtime -> Change runtime type -> T4 GPU. Run all cells.

## Exercises

1. Run with `N = 2^20`, `2^24`, `2^28`. Observe how throughput in GB/s changes — is the kernel memory- or compute-bound at each size?
2. The provided kernel uses `cudaMallocManaged` (Unified Memory). Modify it to use explicit `cudaMalloc` + `cudaMemcpy`. Compare wall times. Where does the difference go?
3. Profile with `ncu` (or AMD `rocprof`). Look at the achieved memory bandwidth as a fraction of peak. SAXPY should hit 80–95% on a well-fed GPU.
4. Re-implement the kernel using **Triton** (`pip install triton`). Compare line counts and performance. Triton's autotuner is doing what a Cray-1 compiler engineer did by hand in 1979.
