# Assessment and Project Guide

This page is for two audiences:

- **Self-paced readers** who want a rubric to know whether they've actually absorbed the course rather than skimmed it.
- **Instructors** adapting the course to a classroom and needing a grading skeleton.

There is no autograder. The course is structured so that the *artifacts you produce* (running code, measured numbers, written analysis) are the assessment. The point is to be able to defend an answer, not to chase points.

## What "completing the course" looks like

A working engineer who has actually done this course should be able to do the following, ideally without consulting notes:

1. **Read any era's code idiomatically.** Given a CAL listing, a piece of vector Fortran with vendor directives, a `C*` whole-array assignment, an MPI halo-exchange function, a CUDA kernel, or a `std::execution::par_unseq` call — explain what abstraction the programmer is using, what the compiler/runtime is being asked to do, and where the parallelism actually lives at execution time.
2. **Read a Top500 spec sheet.** Given any current entry, decode the node configuration (CPU, accelerator, memory hierarchy, intra-node fabric), the inter-node interconnect (topology, bandwidth, latency), and reason about which workloads it will run well and badly.
3. **Predict bottlenecks before measuring.** Given a numerical kernel and a target architecture, predict whether it is compute-bound or memory-bound, what the achievable fraction of peak FLOPS is, and which programming-model decisions matter most. Roofline (Week 15) is the formal version of this skill.
4. **Translate a kernel across eras.** Take a single computation — SAXPY, a 5-point stencil, a sparse matrix-vector multiply — and write it in the idiom of any era from CDC 6600 scalar Fortran to modern standard parallelism. This is the explicit goal of the Week 16 capstone.

If you can do these four things, you have the course.

## Suggested rubric for classroom use

| Component | Weight | What's being measured |
|---|---:|---|
| Lab submissions (one per week, weeks 1–15) | 35% | Code correctness, benchmark discipline, written interpretation of results |
| Architecture comparison essay (mid-course) | 10% | Defended argument about why one era's architecture displaced another, with primary-source citations |
| Midterm take-home | 15% | Performance reasoning across vector, shared-memory, and distributed-memory eras; one worked Roofline analysis |
| Final project proposal | 5% | Scoped comparison plus a reproducibility plan |
| Final project report and presentation | 25% | Empirical comparison with documented methodology and reproducibility appendix |
| Reading discussion participation | 10% | Engagement with the primary sources, not just summaries |

The rubric deliberately weights *measured claims with documented methodology* over *raw speed*. Students should not be punished for running on weaker hardware if their controls and analysis are sound.

## Final project portfolio

The Week 16 capstone (SAXPY across six eras) is the minimum-viable final project. Stronger projects make the same kind of cross-era comparison on a more interesting kernel, or add an empirical dimension (energy, scaling, portability) that the capstone treats lightly.

A portfolio of project shapes that work well:

| Theme | Comparison | Suggested kernel / dataset |
|---|---|---|
| Vector then and now | Scalar Fortran → OpenMP SIMD → ISPC → SVE intrinsics | Synthetic DAXPY / triad |
| From Cray loop to exascale | Cray-era stencil → MPI → MPI + GPU offload | Generated 2D/3D stencil grids; NPB-CG class |
| Bandwidth archaeology | STREAM on a laptop, on AVX-512, on an Apple M-series, on a GPU | STREAM-sized synthetic arrays |
| Sparse irregularity | Scalar C → OpenMP → ISPC gather/scatter → MPI SpMV | A small SuiteSparse matrix (e.g., `bcsstk32`) |
| Climate mini-app port | Same kernel in MPI-only, OpenACC, OpenMP target | [`miniWeather`](https://github.com/mrnorman/miniWeather) — designed for HPC training |
| Dense linear algebra longevity | Naïve `dgemm` → tuned BLAS → cuBLAS / hipBLAS | Generated dense matrices, 4K–32K |
| Roofline study | Same kernel on two architectures, with measured arithmetic intensity placed on a roofline plot | STREAM-derived bandwidth + HPCG kernel |

A publishable project includes a *short* historical framing section — one paragraph showing that the question being asked has roots earlier in the course. A project that begins with a Cray-era loop and ends with a measured SVE or CUDA result is a strong concrete argument about abstraction continuity, and is also a paper-shaped artifact.

## Reproducibility expectations

Every result submission — lab or final — should include:

- Compiler version and flags.
- Hardware: CPU model, GPU model if used, RAM size, interconnect if multi-node.
- Input size and problem class.
- Timing method (wall-clock, CPU time, event-based; warmups; repetitions; statistic reported).
- Software environment (Spack manifest, container hash, or `pip freeze` output for Python labs).

These are not bureaucratic. They are how someone six months from now (including you) can tell whether a number you reported was real.

## Suggested reading memos

For instructors who want a discussion component: assign one of the primary sources from `references.md` per week and have students write a one-page memo answering three questions:

1. What architectural claim is the source making?
2. What evidence is given for the claim, and what evidence is missing?
3. Has the claim aged well? Cite something from a later week's reading.

Three questions, one page. The discipline is to engage directly with the primary text rather than summarize it.

## A note on hardware access

This course is designed to be runnable on a single laptop. Some labs benefit from real cluster or GPU access:

- **MPI labs (9, 10, 15)**: a real multi-node cluster is nicer than Docker containers but not required.
- **CUDA lab (13)**: an NVIDIA GPU is best. Apple Silicon has a Metal alternative we provide. Google Colab (free tier) suffices.
- **SVE-related discussion (14–16)**: actual A64FX or Graviton3 hardware is available through AWS Hpc7g instances, or you can use Arm Instruction Emulator / QEMU under software emulation.

Don't let hardware access become the bottleneck. Methodology and analysis carry more pedagogical weight than peak FLOPS.

### Free educational allocations on real HPC systems

For final projects that need real cluster scale, several US and European programs grant free or low-friction educational allocations:

- **NSF ACCESS** (access-ci.org) — the successor to XSEDE. The "Explore ACCESS" tier provides immediate access for small projects; "Discover" and "Accelerate" for larger needs. Multi-site: TACC, SDSC, PSC, NCSA, Purdue, others. The lowest-friction path to real cluster time for US-based students and researchers.
- **OLCF Director's Discretion** (olcf.ornl.gov) — Frontier and Andes access for projects with a clear scientific or training case. Application is a short proposal.
- **ALCF Director's Discretion** (alcf.anl.gov) — Polaris, Aurora, and AI Testbed access on similar terms.
- **LUMI** (lumi-supercomputer.eu) — the EuroHPC pre-exascale system in Finland. Allocations through LUMI Consortium member countries; small "extreme scale" allocations are available to EU researchers via EuroHPC.
- **EuroHPC JUPITER** — once fully production, will offer benchmark and development access under the EuroHPC JU's standard allocation processes.
- **Google Colab** (colab.research.google.com) — free-tier T4 GPU, paid tier for A100/L4. The lowest-friction GPU access anywhere.
- **AWS HPC educate** credits and **Azure for Research** — academic credit programs for cloud HPC, useful for the Beowulf-style labs and for ParallelCluster work.

Application processes vary from "submit a one-page form" (Colab, ACCESS Explore) to "write a five-page proposal with a science case" (OLCF DD, LUMI extreme scale). Plan ahead. Allocations on the real machines are competitive and worth practicing for, even if you don't end up using them — the proposal-writing process is itself a useful HPC skill.
