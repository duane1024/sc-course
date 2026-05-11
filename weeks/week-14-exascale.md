# Week 14 — Exascale: Frontier, Aurora, El Capitan, Fugaku

## Where we are in 2026

Four machines define the present. Three of them — **Frontier**, **Aurora**, **El Capitan** — are American CPU-plus-GPU systems sitting on the post-2022 exascale plateau. One of them — **Fugaku** — is a Japanese ARM-with-wide-vectors machine that is the major architectural exception to the GPU consensus. Together they map the design space available to anyone building HPC at the high end in 2025–2030.

This week is the four machines, what they share, what they don't, and what each is good at.

## Frontier (2022): the first exaflop

- **Site**: Oak Ridge National Laboratory.
- **Vendor**: HPE (the merged Cray + HPE Cray business).
- **Compute**: 9,408 nodes. Each node = 1× AMD EPYC "Trento" 7A53 CPU (64 cores) + 4× AMD Instinct MI250X GPUs.
- **Per node**: ~84 TFLOPS FP64 from the GPUs; the CPU is mostly traffic cop.
- **Total**: debuted at 1.102 EFLOPS LINPACK sustained in June 2022, the first machine to break the exaflop barrier on HPL; later public Top500 results are about 1.35 EFLOPS.
- **Interconnect**: HPE **Slingshot-11**, 200 Gb/s per port, dragonfly topology. Three planes for compute, with separate planes for storage.
- **Power**: 21 MW. ~52 GFLOPS/W on HPL — winner of Green500 #1 at the time of debut.
- **Cooling**: direct liquid cooling, warm-water (the cooling water comes in at ~30°C and leaves at ~40°C; no chillers, just cooling towers).
- **Cost**: ~$600M.

*Sources for Frontier specifications: Atchley et al. (2023), "Frontier: Exploring exascale" (SC23), for node configuration, GPU and CPU details, and system topology; ORNL OLCF Frontier user documentation (olcf.ornl.gov/frontier) for storage and operational figures; Top500 June 2022 list for the 1.102 EFLOPS debut HPL, June 2025 list for ~1.35 EFLOPS; Green500 June 2022 for the 52 GFLOPS/W debut.*

Frontier's architectural pattern is the canonical 2020s pattern: a few CPUs per node managing many GPUs, fast intra-node interconnect (Infinity Fabric for AMD GPUs; NVLink for NVIDIA), and a serious inter-node fabric (Slingshot, NDR InfiniBand). The CPU exists to feed the GPUs and run the parts of the application that don't accelerate well.

The MI250X GPU is itself two graphics compute dies in one package: an AMD multi-die/MCM GPU. On the spec sheet you have 4 GPUs per node, but it's actually 8 graphics compute dies. The **exposed** unit is "Graphics Compute Die" (GCD); CUDA-equivalent code is written per-GCD, not per-package.

## Aurora (2023, fully online 2024)

- **Site**: Argonne National Laboratory.
- **Vendor**: Intel + HPE.
- **Compute**: 10,624 nodes. Each node = 2× Intel Xeon Max ("Sapphire Rapids HBM") CPUs + 6× Intel Data Center GPU Max ("Ponte Vecchio") GPUs.
- **Per node**: ~131 TFLOPS FP64.
- **Total**: 1.012 EFLOPS LINPACK (June 2024).
- **Interconnect**: HPE Slingshot-11, dragonfly.
- **Power**: ~38 MW. Roughly 27 GFLOPS/W — significantly less efficient than Frontier.
- **Cooling**: direct liquid cooling.
- **Cost**: ~$500M.

*Sources for Aurora specifications: ANL ALCF Aurora user documentation (alcf.anl.gov/aurora) for node configuration, GPU/CPU breakdown, and DAOS storage; Top500 June 2024 list for the 1.012 EFLOPS HPL Rmax; Green500 entries 2024 for power efficiency.*

Aurora was originally announced in 2015 to use Intel Xeon Phi accelerators and to ship in 2018. It was redesigned multiple times when Xeon Phi was canceled (2018) and then again as Ponte Vecchio's schedule slipped. Aurora's eventual debut at #2 (behind Frontier) closed a chapter for Intel: Ponte Vecchio is competitive enough to make Aurora an exascale system, but Intel's accelerator roadmap has been reset more than once since then. Treat Aurora as an important production machine and as a cautionary example about relying on a vendor roadmap at decade scale.

## El Capitan (2024)

- **Site**: Lawrence Livermore National Laboratory.
- **Vendor**: HPE / AMD.
- **Compute**: 11,039 nodes. Each node = 4× AMD Instinct MI300A APUs.
- **Total**: 1.742 EFLOPS LINPACK on its November 2024 debut; about 1.81 EFLOPS on the November 2025 Top500 list. Currently #1 on the Top500 as of that list.
- **Interconnect**: Slingshot-11.
- **Power**: ~30 MW. Roughly 60 GFLOPS/W on HPL in current public list results, ahead of Frontier on the same metric.
- **Cooling**: direct liquid cooling.

*Sources for El Capitan specifications: Garcia et al. (2022), "El Capitan: An advanced architecture exascale system at LLNL" (SC22), for the planned MI300A node design; LLNL Livermore Computing El Capitan platform pages (hpc.llnl.gov) for the as-deployed node count; Top500 November 2024 list for the debut 1.742 EFLOPS HPL Rmax; Top500 November 2025 list for the updated ~1.81 EFLOPS figure.*

The architectural innovation in El Capitan is the **APU**. The MI300A integrates CPU and GPU dies on the same package, sharing a coherent address space and HBM stacks. There is no PCIe between the CPU and GPU on the same package — they share memory at memory-bus speed. This eliminates a huge category of CPU-GPU data-movement headaches that have plagued every accelerated HPC system since Roadrunner.

The MI300A is, in some sense, where the industry has been heading since heterogeneous systems began: collapse the host-and-accelerator distinction into a single coherent compute substrate. NVIDIA's response is the Grace-Hopper Superchip (a Grace CPU and a Hopper GPU on a single board, connected by NVLink-C2C, with a unified memory abstraction); the next-generation Grace-Blackwell continues the pattern. The lines are blurring.

## Fugaku (2020): the exception

- **Site**: RIKEN Center for Computational Science, Kobe.
- **Vendor**: Fujitsu.
- **Compute**: 158,976 nodes. **Each node = 1 Fujitsu A64FX chip and nothing else.**
- **Per node**: 48 cores + 4 assistant cores, ARM v8.2-A with **SVE** (Scalable Vector Extension) at 512-bit.
- **Per chip**: 32 GB HBM2 (no DRAM), 1 TB/s memory bandwidth.
- **Total**: ~7 million cores, 442 PFLOPS LINPACK (June 2020) — held #1 for two years.
- **Interconnect**: Tofu-D, a 6D-torus-of-something custom interconnect, specifically designed for the workloads RIKEN cares about.
- **Power**: 28 MW. ~16 GFLOPS/W — much *less* efficient than the GPU-based machines on HPL. Fugaku led HPCG for several lists and remains one of the strongest systems on that memory-bound benchmark, but it is no longer #1 as of the November 2025 HPCG list.
- **Cooling**: direct liquid cooling.

*Sources for Fugaku specifications: Sato et al. (2020), "Co-design for A64FX manycore processor and Fugaku" (SC20), for the A64FX architecture, SVE design, HBM2 bandwidth, and Tofu-D interconnect; Top500 June 2020 list for the 442 PFLOPS Rmax debut; HPCG list 2020–2024 for Fugaku's memory-bound benchmark performance; RIKEN R-CCS Fugaku machine documentation for node count and operational details.*

Fugaku is the architectural counter-argument. Rather than CPU + GPU, it goes "CPU only — but with vector units so wide and memory bandwidth so high that the GPU isn't needed." Each A64FX core supports 512-bit SVE operations, with high aggregate HBM2 bandwidth directly attached to the chip. Comparing "per-core" CPU bandwidth to GPU bandwidth is awkward because a GPU's execution units are organized differently, but the point stands: A64FX spends far more silicon budget on memory bandwidth per unit of scalar/vector CPU throughput than ordinary server CPUs do.

For the workloads that Japanese national institutions actually run — climate models, structural simulations, drug-discovery codes — Fugaku can be a better fit than a GPU-heavy system when the application is limited by memory bandwidth, latency, or CPU control flow rather than dense matrix throughput. On HPL it is much slower than the exascale GPU machines; on HPCG its ratio of useful sparse-solver work to HPL peak is still unusually strong. The Earth Simulator's lesson, applied at exascale.

The architectural success of Fugaku revives a question every HPC architect re-asks: **does the workload genuinely need the per-flop throughput of GPUs, or is it bandwidth-bound, in which case a wide-SIMD CPU with HBM is sufficient?** For climate, weather, and a chunk of CFD: bandwidth-bound. For dense linear algebra and AI training: throughput-bound. Different workloads, different answers.

### What SVE code looks like

SVE's signature design choice is **vector-length agnosticism**: the hardware vector width is *not encoded in the program*. The same binary runs efficiently on chips with 128-bit, 256-bit, 512-bit, or wider vectors. The programmer writes a loop with a predicate that masks off lanes past the array end:

```c
#include <arm_sve.h>

void daxpy_sve(size_t n, double a, const double *x, double *y) {
    for (size_t i = 0; i < n; i += svcntd()) {
        svbool_t   pg = svwhilelt_b64(i, n);     // active lanes for this chunk
        svfloat64_t xv = svld1(pg, &x[i]);
        svfloat64_t yv = svld1(pg, &y[i]);
        yv = svmla_f64_m(pg, yv, xv, svdup_f64(a));   // y += a*x, masked
        svst1(pg, &y[i], yv);
    }
}
```

There is no `8` or `16` in the loop. `svcntd()` returns the runtime double count, `svwhilelt_b64` builds the per-lane mask, and every operation is *predicated* on that mask. On an A64FX core (512-bit), each iteration processes 8 doubles; on a future 1024-bit Arm chip the same binary processes 16. *The Cray-1's strip-mining wrapper has been moved inside the ISA.*

This is the architectural strength of Fugaku: SVE code compiled once will run efficiently on every future Arm HPC chip without recompilation, because the program never asserted a width. Stephens et al. (2017) describes the design rationale; the worked example above is in the report's "Further reading."

## What's the "vector processing as a mainstream capability" picture, then?

Every machine on this list runs vector code:

- **Frontier**: SIMT/SIMD on AMD GPUs. Vector lanes 64 wide (AMD wavefronts).
- **Aurora**: SIMT on Intel GPU Max (8-wide SIMD per Xe-vector engine, 8 of them per Xe-core, organized in subslices).
- **El Capitan**: SIMT on AMD GPU dies (same wavefront concept), unified with CPU AVX/AVX-512 vectors via shared HBM.
- **Fugaku**: ARM SVE 512-bit vectors in each A64FX core, with multiple vector pipelines per core.
- **Modern x86 CPUs in any of the above as host**: AVX-512.

Cray-1 had 8 vector registers of 64 elements at 80 MHz with one functional unit per type, hitting 160 MFLOPS. A modern A64FX core has SVE registers of 8 doubles at ~2 GHz with two FMA pipelines, hitting ~32 GFLOPS per core × 48 cores = 1.5 TFLOPS per chip. **Per-chip, that's 10,000× the Cray-1.**

But the *idea* is the same: pipeline-friendly vector instructions operating on registers full of data, fed by a memory subsystem deliberately engineered to keep them fed, with the loop-overhead amortized across the vector. Cray's bet went mainstream. The Cray-1 of 1976 is not where modern HPC stops — it's the architectural pattern modern HPC is *built out of*.

## What does code look like, in 2026, on these machines?

Here's the honest answer: it depends on how recent the code is.

1. **A 1995 MPI Fortran code** running on Frontier: recompiled with `cc`/`ftn` (HPE's wrapper), runs on the CPU only, gets a few percent of peak. *Real codes are often in this state.*
2. **A 2010-era MPI + OpenMP code**: same situation, slightly better single-node performance.
3. **A modern code targeting GPUs**: written with one of:
   - **CUDA / HIP** directly. Maximal performance, vendor-locked.
   - **OpenMP target offload** (`#pragma omp target teams distribute parallel for`). Portable, with performance that ranges from excellent to disappointing depending on compiler, kernel, and memory behavior.
   - **Kokkos / Raja / SYCL**: portable C++ abstractions. Often competitive with native backends on well-tuned kernels, but not automatically so.
   - **Standard Parallelism in C++23/26 (`std::execution::par_unseq`)** or **Fortran 2018 `do concurrent`**. The compiler generates GPU code if you compile with NVHPC or Cray CCE's offload mode. The *most* portable; performance varies.
4. **A 2020-era ML training code**: PyTorch / JAX / Triton, on top of CUDA / ROCm / XLA. Different software stack, same hardware.

The best-case sustained efficiency on real applications, on a modern exascale system, is around 20–40% of peak FP64. That's *worse* than the Earth Simulator's 87%. Why? The bytes-per-flop ratio of GPUs has fallen below what most non-GEMM applications need. We're memory-bandwidth-bound on the workloads people actually run. For pure GEMM (LINPACK, AI training), the ratio is fine and we get high efficiency. For everything else, we don't.

This is the central architectural challenge of the next decade: fix the bytes-per-flop, or accept that a lot of useful applications run at <10% of peak.

## Lab — Read a job script

In `labs/14-job-scripts/` we provide three heavily commented job-script examples — one for Frontier, one Aurora-style PBS script, and one Fugaku-style PJM script translated into a Slurm-like shape for comparison. You read them, identify the architectural assumptions baked in (per-node GPU counts, memory binding, interconnect tuning flags), and adapt one to run on a small Slurm cluster (which we set up in lab 10).

You won't run a job on Frontier from your laptop. But you'll know what someone running a job on Frontier writes.

## Discussion questions

1. Frontier (CPU+GPU) and Fugaku (CPU only with wide vectors) reach roughly comparable performance on bandwidth-bound applications. They differ enormously on dense-linear-algebra benchmarks. Which architecture would you bet on for the next decade, and why? What workload mix would change your answer?
2. The MI300A APU collapses the CPU/GPU distinction. NVIDIA Grace-Blackwell does the same with NVLink-C2C. Both are described as "memory-coherent." How is this different from the original goal of "shared memory multiprocessing" the Cray X-MP/Y-MP shipped in 1985? What does it cost?
3. Fugaku reached #1 with no GPUs. Aurora reached the exascale list using Intel GPUs that are now end-of-line. What does this say about how to evaluate an HPC architecture's *durability* as opposed to its peak benchmark performance?

## Further reading

- Atchley, S. et al. (2023). "Frontier: Exploring exascale". *Proc. SC23*.
- Sato, M. et al. (2020). "Co-design for A64FX manycore processor and Fugaku". *Proc. SC20*.
- Argonne ALCF documentation (alcf.anl.gov/aurora) for Aurora architecture.
- LLNL HPC Center documentation (hpc.llnl.gov/hardware/compute-platforms/el-capitan) for El Capitan architecture.
- Top500 / HPCG list, current. Watch Fugaku's HPCG ranking versus its HPL ranking.
- ECP Software Technology Capability Assessment Reports (ECP, multi-year). Honest discussion of how well real codes are running on exascale machines.
