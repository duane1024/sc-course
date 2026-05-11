# Week 13 — CUDA and SIMT: Vectors Reborn as Threads

## Where we are in 2026

Open the spec sheet for any current Top500 system: most of the highest-FLOP systems get their arithmetic throughput from GPUs or GPU-like accelerators. NVIDIA H100, AMD MI300-class parts, Intel Ponte Vecchio. Much of modern AI training runs on the same accelerator pattern, though TPUs, Trainium, Cerebras, and other AI-specific systems are important counterexamples. That hardware is, *internally*, a vector machine — descendant of the Cray-1's idea — wrapped in a programming abstraction that hides the vector ISA behind threads. The model is called **SIMT** — Single Instruction, Multiple Threads — and it was named, productized, and widely deployed by NVIDIA with **CUDA** in 2006.

This week is the architecture and the programming model.

## Where GPUs came from

Before they were "GPUs", they were "graphics accelerators": fixed-function chips that drew triangles to a frame buffer. The 1990s milestones were 3dfx Voodoo (1996), NVIDIA RIVA 128 (1997), NVIDIA GeForce 256 (1999, the chip NVIDIA branded as the "first GPU"). These were unprogrammable — you fed them vertex and texture data, they produced pixels.

Around 2001 the ARB and DirectX 8 specs added **programmable shaders**: small fragments of code (vertex shaders, then pixel shaders) that ran per-vertex or per-pixel. Suddenly the GPU was a *programmable* parallel processor. People started doing physics simulations and matrix multiplies by tricking the shader pipeline into computing them. The early GPGPU papers (Owens et al., 2004) made the trick respectable but tedious — you had to format your data as textures, write vertex shaders that did your computation, read the result out of the framebuffer.

NVIDIA's bet, made around 2003 and shipped with the **G80** chip in 2006, was to build a GPU that exposed a *first-class general-purpose programming model*, not just a shader language. That was CUDA.

## The G80 (2006) and the SIMT idea

- **128 "stream processors"** (in NVIDIA marketing). Internally: 16 multiprocessors of 8 lanes each.
- Each multiprocessor executed instructions in **warps of 32 threads**. All 32 threads in a warp run the same instruction at the same time, on different data, like a 32-wide SIMD lane.
- The hardware handled **branch divergence**: when the threads in a warp took different paths in an `if`, the warp executed both paths sequentially, with each thread masked off when its path wasn't running. Slow, but correct.
- Each thread had **its own registers and its own stack**, so you could write arbitrary scalar code per thread, and the hardware would aggregate it into vector-style execution where possible.
- Threads were grouped into **thread blocks** (typically 128 to 1024 threads), which shared a small fast on-chip "shared memory" (16 KB on G80, programmer-managed scratch).
- Many thread blocks per **grid**, organized in 1D, 2D, or 3D, with the hardware scheduling them across multiprocessors.

This is **SIMT**: write code that looks scalar, per-thread; the hardware groups threads into warps and executes them SIMD-style. It is, conceptually, the Connection Machine's fine-grained parallelism with a *much* better story for irregular control flow.

The architectural insight: **a vector ISA is great when control flow is uniform; threads with masks are great when control flow is non-uniform.** SIMT gets you both — the uniform case runs at full SIMD throughput, the non-uniform case runs at degraded but still correct throughput, *and the source code is the same in both cases.*

## CUDA in five lines

The minimal CUDA program — vector add:

```c
__global__ void add(float* a, float* b, float* c, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) c[i] = a[i] + b[i];
}

int main(void) {
    int n = 1<<20;
    float *a, *b, *c;
    cudaMallocManaged(&a, n*sizeof(float));
    cudaMallocManaged(&b, n*sizeof(float));
    cudaMallocManaged(&c, n*sizeof(float));

    for (int i = 0; i < n; i++) { a[i] = i; b[i] = 2*i; }

    int block = 256;
    int grid  = (n + block - 1) / block;
    add<<<grid, block>>>(a, b, c, n);
    cudaDeviceSynchronize();

    cudaFree(a); cudaFree(b); cudaFree(c);
    return 0;
}
```

The `__global__` qualifier marks `add` as a function that runs on the device. The `<<<grid, block>>>` syntax launches one thread per `(blockIdx, threadIdx)` pair in the grid. Each thread computes its own array index from its block and thread coordinates and does one element of the vector add.

Compare to the Cray-1 CAL listing for SAXPY from Week 2:

```text
        VL      A1
        V0      ,A2,1
        V1      ,A3,1
        V2      S1*V0
        V1      V1+V2
        ,A3,1   V1
```

These are the **same algorithm**. The CUDA version is a per-thread description of one element's worth of work, which the hardware aggregates into 32-wide warps that execute as a vector. The CAL version is an explicit vector instruction over a vector register. Different abstraction surface, similar machine underneath.

## Why CUDA and SIMT won

Three reasons:

1. **Programming model fit the workload.** Image, video, signal-processing, neural network workloads are mostly per-pixel-or-per-element computation. Per-thread programming with implicit warp aggregation matches that mental model exactly.
2. **The hardware was already being built at scale for graphics.** NVIDIA was selling tens of millions of GPUs to gamers; the per-unit cost of an accelerator chip was a small fraction of what custom HPC silicon cost. The volume economics that killed bespoke vector machines (Week 6) now favored GPUs.
3. **Early DOE / Top500 commitment.** Roadrunner (LANL, 2008) was the first hybrid CPU+accelerator petaflop machine, using IBM Cell BE accelerators. Cell didn't last, but the *pattern* — fat host nodes with PCIe accelerators, application split into host code and accelerator code — became the template. **Tianhe-1A** (NUDT, China, 2010) was the first GPU-accelerated Top500 #1, using NVIDIA Tesla M2050s — the moment GPU acceleration crossed from research project to leadership-class architecture. **Titan** (ORNL, 2012) was the first US GPU-accelerated #1, using NVIDIA Kepler K20Xs. **Summit** (ORNL, 2018), IBM POWER9 + NVIDIA Volta V100, held #1 from June 2018 to June 2020. By Summit, GPU acceleration was no longer a bet; it was the default.

## The GPU generation roadmap

| Year | NVIDIA arch | Per-chip peak FP64 | Memory | Notable |
|------|-------------|--------------------|--------|---------|
| 2006 | G80 (Tesla) | n/a (no FP64) | 1.5 GB GDDR3 | First CUDA GPU |
| 2008 | GT200 | 78 GFLOPS | 4 GB GDDR3 | First scientific FP64 |
| 2010 | Fermi (GF100) | 515 GFLOPS | 6 GB GDDR5 | ECC memory, real cache |
| 2012 | Kepler (GK110) | 1.3 TFLOPS | 6 GB GDDR5 | Titan |
| 2014 | Maxwell (GM200) | 200 GFLOPS FP64 | — | (consumer-skewed) |
| 2016 | Pascal (P100) | 4.7 TFLOPS | 16 GB HBM2 | NVLink, HBM |
| 2017 | Volta (V100) | 7.8 TFLOPS | 16 GB HBM2 | First Tensor Cores, Summit |
| 2020 | Ampere (A100) | 9.7 TFLOPS | 80 GB HBM2e | Modern AI standard |
| 2022 | Hopper (H100) | 34 TFLOPS | 80 GB HBM3 | Transformer engine |
| 2024 | Blackwell (B200) | 40 TFLOPS | 180 GB HBM3e | NVLink-72 |

Two trends are visible: (1) FP64 throughput scaled aggressively until ~2020, then leveled off as AI workloads pulled R&D toward FP16 / FP8 / FP4. (2) Memory capacity and bandwidth grew steadily. The per-chip FLOPS-per-watt has improved more than 100× since G80.

## What about AMD and Intel?

NVIDIA dominates, but is not alone:

- **AMD ROCm / HIP**: AMD's CUDA-equivalent stack. HIP is source-compatible with CUDA — many CUDA programs port with `s/cuda/hip/g` and a recompile. Frontier (ORNL, 2022) and El Capitan (LLNL, 2024) run on AMD Instinct MI250X / MI300A.
- **Intel oneAPI / SYCL**: Intel's open standard, based on Khronos's SYCL specification. Aurora (Argonne, 2023) runs Intel Ponte Vecchio (Data Center GPU Max) accelerators programmed in SYCL.
- **Open alternatives**: OpenMP target offload, OpenACC, Kokkos, Raja, Triton (an OpenAI-led JIT for tensor kernels). These let you write portable code that compiles to any of CUDA, HIP, or SYCL.

The architectural patterns are convergent. All three vendors build SIMT-like execution units, HBM memory, NVLink-or-equivalent inter-GPU fabric, host-device unified addressing. The wars are at the software stack level, not the architecture level.

## SIMT is vector with a different abstraction surface

Look hard at what SIMT actually does:

- **At the hardware level**: 32 lanes of SIMD, with per-lane masks for divergence handling.
- **At the abstraction level**: 32 threads per warp, each appearing to execute independently.

This is the *exact* trade-off Cray made differently. Cray exposed the vector register and made the programmer (or compiler) write vector code. SIMT hides the vector and makes the programmer (or compiler) write thread code.

For workloads where both work — uniform stride-1 arithmetic — they are equivalent. For workloads with branches and gathers, SIMT degrades gracefully (warp divergence, slow but correct) while classical vector ISAs handle it badly (gather/scatter with serialization, masked execution as bolt-on).

The architecturally interesting result is: **modern CPUs are growing toward SIMT**. ARM SVE2's "vector-length agnostic" predicated execution, RISC-V V's masked vector ops, Intel AVX-512's per-lane masks, the proliferation of `vcompress`/`vexpand` instructions — all of these are walking the CPU vector ISA toward what GPUs already are. The two architectural lines (CPU SIMD, GPU SIMT) are converging.

### Sidebar: ISPC, or SIMT on the CPU

If SIMT is just "write per-element code and let the runtime aggregate into vector lanes," that's an abstraction, not a hardware requirement. Could you write CPU code that thinks in SIMT-style and have a compiler map it onto AVX-512 or NEON? Yes — that's exactly what Intel's open-source **ISPC** (Implicit SPMD Program Compiler, Pharr & Mark 2012) does. The same SAXPY kernel:

```ispc
export void saxpy(uniform int n, uniform float a,
                  uniform float x[], uniform float y[]) {
    foreach (i = 0 ... n) {
        y[i] = a * x[i] + y[i];
    }
}
```

`foreach` declares "this loop body is per-element parallel." The compiler emits a `gang` of program instances, each running on a SIMD lane (8 lanes on AVX-512, 4 on AVX2, etc.). Branches that diverge across lanes get masked. Reductions get tree-reduced across lanes. Gather/scatter loads compile to `vgatherdps`/`vscatterdps`.

The lesson is that SIMT is a *programming-model* idea, not a GPU-only idea. Treat ISPC as the missing intellectual bridge between "I write CUDA kernels" and "I get good AVX-512 throughput on a CPU." The same mental model applies to both.

Pharr's argument is worth reading in its original form (linked in `references.md`). The 2012 paper makes the case more clearly than any tutorial: the SPMD-on-SIMD style was developed for GPUs because GPUs forced it, but it's a better way to think about CPU vectorization than what most compilers do with auto-vectorization.

## What about non-NVIDIA accelerators in HPC?

Worth mentioning briefly:

- **Cell BE** (Sony/Toshiba/IBM, ~2005): the Roadrunner accelerator. PowerPC + 8 SPE (Synergistic Processing Element) vector cores. Hard to program. Lasted one HPC generation.
- **Intel Xeon Phi / Knights Landing** (2010s): Intel's "many-core x86" attempt. Had some traction (Tianhe-2 in 2013 used the prior generation). Discontinued in 2018 when Intel pivoted to discrete GPUs.
- **Fujitsu A64FX** (2019, in Fugaku): not an accelerator — it's the *only* compute on Fugaku nodes. ARM with SVE 512-bit vectors. *No GPU at all.* Fugaku ran #1 Top500 for two years (June 2020 to June 2022). It is the only major architectural counterexample to "modern HPC = CPU host + GPU accelerator", and we discuss it next week.

## Lab — Run CUDA on your laptop

In `labs/13-cuda-saxpy/`, you have three options:

1. **You have an NVIDIA GPU on your laptop**: install CUDA Toolkit, compile and run the provided SAXPY kernel. Profile with `nsys` and `ncu`.
2. **You have an Apple Silicon Mac**: run the provided Metal or MLX SAXPY version on the Apple GPU.
3. **You have neither**: run the provided Colab notebook on a free-tier NVIDIA GPU.

The provided kernel is deliberately just SAXPY so the memory-bandwidth story is visible. Optional extensions ask you to try explicit CUDA copies, Triton, and larger problem sizes.

## Discussion questions

1. SIMT degrades gracefully under branch divergence; classical SIMD does not. But modern CPUs (AVX-512, SVE) have predicated execution. Are CPUs becoming SIMT? What's still different?
2. The Cell BE was technically interesting and commercially short-lived. The Cell programmer had to manually orchestrate data motion to and from the SPE local stores. CUDA hid that with cache-and-memory-hierarchy abstractions. What lesson does the comparison suggest about *which* parts of an architecture should be exposed to programmers and which should be abstracted away?
3. NVIDIA's market dominance in HPC accelerators (~80% of Top500 accelerated FLOPS as of 2024) is partly architectural quality, partly software ecosystem (CUDA), partly first-mover. What would have to be true for AMD ROCm or Intel oneAPI to genuinely compete? Is the answer "a 10× hardware advantage" or "a 10× software advantage"?

## Further reading

- Lindholm, E. et al. (2008). "NVIDIA Tesla: A unified graphics and computing architecture". *IEEE Micro*. The G80 paper.
- Nickolls, J. & Dally, W. (2010). "The GPU computing era". *IEEE Micro*.
- Owens, J.D. et al. (2007). "A survey of general-purpose computation on graphics hardware". *Computer Graphics Forum*. Pre-CUDA GPGPU.
- The CUDA Programming Guide (current version on docs.nvidia.com). Required reference.
- Volkov, V. (2010). "Better performance at lower occupancy". *GTC*. Influential on how to think about GPU performance models.
- For SIMT-vs-SIMD intellectual history: Hennessy & Patterson, 6th ed., chapter 4.
