# Introduction

*By Duane Moore.*

In June 1976 a refrigerator-sized arc of beige metal and brown vinyl arrived at Los Alamos National Laboratory. It weighed five tons, drank 115 kilowatts, was cooled by liquid Freon piped through its frame, and could perform 160 million floating-point operations per second. It cost $8.8 million in 1976 dollars. It was called the Cray-1, and for most people in the field it was the moment the word **supercomputer** stopped being a vague honorific and became the name of a specific kind of machine.

A modern Apple M-series laptop, fanless and battery-powered, performs about a hundred billion floating-point operations per second on its CPU alone — six hundred Cray-1s. A single NVIDIA H100 SXM GPU performs about **two hundred thousand Cray-1s** at FP64, or more than four hundred thousand if you count its FP64 Tensor Core peak. Frontier, the first machine to clear the exaflop barrier (June 2022, Oak Ridge National Laboratory), performs roughly **seven billion Cray-1s** in parallel.

But raw arithmetic isn't the interesting part. The interesting part is that those seven billion Cray-1-equivalents are *not arranged like a Cray-1*. The Cray-1 was a single thinking machine — one program, one address space, one absurdly fast scalar-and-vector pipeline. Frontier is a tightly-coupled datacenter: 9,408 nodes, each with a 64-core CPU and four GPUs, lashed together with a custom HPE Slingshot-11 network, presented as a single logical machine but only when your code is written to think that way.

That difference — between *one fast machine* and *one fast collection of machines* — is the story of this course. It is not a clean monotonic progression. It is a forty-year fight between three architectural philosophies:

1. **Make one CPU as fast as you possibly can.** (Cray-1, X-MP, Cray-2, ETA-10, Cray-3.)
2. **Connect a huge number of small CPUs.** (Connection Machine, Intel Paragon, Cray T3E, BlueGene, Beowulf.)
3. **Connect a moderate number of CPUs to specialized accelerators that are themselves doing #1 internally.** (Roadrunner, Titan, Summit, Frontier, Aurora, El Capitan.)

Vector processing — the thing the Cray-1 made famous — won, then lost, then won again in disguise. Today every laptop CPU has SIMD vector units (AVX, NEON, SVE), every GPU is essentially a wide vector machine with branch-divergence handling, and the workloads that drive the Top500 are matrix multiplies — which is to say, *exactly the workload Cray designed for in 1972*. But the hardware running those workloads is not what Cray would have built. Understanding why is the whole point.

The central thesis of this course, stated once: **vector thinking migrates from era to era; it never disappears.** It moves from Cray-1 vector registers (1976) into vectorizing Fortran compilers (1978) into shared-memory vector multiprocessors (1982) into massively-parallel SIMD machines (1985) into multimedia SIMD instructions on commodity CPUs (1996) into GPU SIMT (2006) into AVX-512 and ARM SVE (2010s) and finally into the wide vector lanes of every exascale node. The *abstractions* over vector hardware change — vector registers, vector intrinsics, SIMT threads, predicated vector-length-agnostic loops, standard-library parallel algorithms — but the underlying engineering bet stays the same: *amortize instruction control over many elements, and engineer the memory subsystem hard enough to keep those elements arriving.* Everything else in this course is a variation on that one bet.

## How this course is structured

Fifteen weeks. Each week is a chapter. Each chapter has:

- **Where we are in 2026** — the bottom-line takeaway, in plain language, before any history.
- **What the machine was** — architecture, clock, memory, interconnect, peak FLOPS, what made it distinctive.
- **What the code looked like** — the actual programming model. We show real code: CAL listings, Fortran with vendor directives, `C*`, MPI, CUDA, and modern C++ parallel algorithms.
- **Why it won. Why it lost.** — what real-world workload validated this architecture, and what undercut it.
- **Lab** — a runnable exercise on your laptop. Often we use modern stand-ins for vanished hardware.
- **Discussion questions** — for self-study or a classroom.
- **Further reading** — primary sources where possible. Trip reports, retrospectives, machine manuals.

The labs assume a Linux or macOS laptop with a C/C++ compiler, Python, NumPy, and (for later weeks) MPICH and either an NVIDIA GPU or a Google Colab account. Setup instructions are in each lab folder.

## A note on getting it right

Computer history is contentious. Different people will tell you the first supercomputer was the IBM 7030 Stretch (1961), or the CDC 6600 (1964), or the Cray-1 (1976). Different people will tell you the Connection Machine was a brilliant dead end or a generation-ahead vision that lost to commodity inertia. Different people will tell you the Earth Simulator's 2002 #1 finish was a wake-up call or a pyrrhic victory. Where these debates exist, the course presents the strongest version of each argument and then tells you which one I think the evidence favors. You're a working engineer; you can decide.

## What you should be able to do at the end

- Explain why a Cray-1 was fast, in terms a 1976 engineer would recognize and a 2026 engineer can use.
- Read CAL, vector Fortran, `C*`, MPI, CUDA, and modern parallel C++, and explain what each one is hiding from you.
- Look at any machine on the Top500 and decode its architecture — node count, accelerator type, interconnect topology — from the spec sheet alone.
- Take a kernel — say, SAXPY or a 5-point stencil — and re-implement it in the idiom of any of the six eras we cover.
- Form a defensible opinion about whether modern "supercomputers" are the descendants of the Cray-1, or something else entirely with the same name.

Let's start in 1964, with a quiet engineer in Chippewa Falls, Wisconsin, who was about to embarrass IBM.
