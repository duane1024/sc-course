# Era 6 — Modern Standard Parallelism (~2023)

The same kernel using language-standard parallelism. Same source, multiple targets. Compile with NVHPC and you get GPU offload; compile with stock g++/clang and the result depends on the standard library backend available on your system.

## C++23 / C++26 standard parallelism

```bash
# CPU path; parallel execution may require a PSTL/oneTBB-enabled standard library
g++ -O3 -std=c++20 -ltbb saxpy_stdpar.cpp -o saxpy_stdpar
./saxpy_stdpar

# GPU offload (if you have NVHPC and an NVIDIA GPU)
nvc++ -O3 -std=c++20 -stdpar=gpu saxpy_stdpar.cpp -o saxpy_stdpar_gpu
./saxpy_stdpar_gpu
```

## Fortran 2018 `do concurrent`

```bash
gfortran -O3 -fopenmp saxpy.f90 -o saxpy_fc           # CPU
nvfortran -O3 -stdpar=gpu saxpy.f90 -o saxpy_fc_gpu   # GPU
```

## What's interesting

Look at the `transform` call:

```cpp
std::transform(std::execution::par_unseq,
               x.begin(), x.end(), y.begin(), y.begin(),
               [a](double xi, double yi) { return a*xi + yi; });
```

This is *the same idea* as Cray's auto-vectorization in 1976 — you describe the per-element computation, the compiler/runtime handles the parallelism — but at a *much* higher level of abstraction. Depending on compiler and backend support, this source can run on:

- A 2025 ARM laptop CPU with NEON, vectorized and sometimes threaded.
- An x86 server with AVX-512, vectorized and sometimes threaded.
- An NVIDIA GPU with SIMT warps.
- Other accelerator backends as compiler support matures.

One source. Five hardware targets. Cray would have argued with the *details* of how the compiler picks among them. He would have been completely on board with the idea.

## Sibling: Kokkos (`saxpy_kokkos.cpp`)

The standard-library route (`std::execution::par_unseq`, `do concurrent`) is *one* way to write performance-portable parallel C++. The dominant alternative in DOE production codes is **Kokkos** (Sandia, ~2011), a C++ template library that exposes parallel patterns (`parallel_for`, `parallel_reduce`, `parallel_scan`) parameterized over an execution space chosen at compile time.

`saxpy_kokkos.cpp` shows the same SAXPY kernel as a `Kokkos::parallel_for`. Build Kokkos with the OpenMP backend and you get threaded CPU code; build it with `-DKokkos_ENABLE_CUDA=ON` and the same source compiles to a CUDA kernel; same for HIP (AMD) and SYCL (Intel). The code does not change; the backend does.

Kokkos won out over the standard-library route in DOE because (a) it shipped years earlier, (b) its abstractions handle multi-dimensional views and complex memory-space semantics that `std::vector` does not, and (c) Sandia put substantial engineering effort into the implementation. Most DOE codes targeting Frontier, El Capitan, and Aurora go through Kokkos or its sibling RAJA (LLNL). Standard-library parallelism is the more *language-purist* path; Kokkos is the more *currently-used-by-production-codes* path. Both exist for the same reason.
