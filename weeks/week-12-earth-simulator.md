# Week 12 — The Earth Simulator: When Vectors Briefly Won Again

## Where we are in 2026

In June 2002, the Top500 list arrived with a surprise: the world's fastest supercomputer was not American, was not a cluster of microprocessors, and was not at a US national lab. It was a Japanese vector supercomputer, the **Earth Simulator**, at the Japan Marine Science and Technology Center in Yokohama. It was 2.6 times faster than the previous #1 (IBM ASCI White). It ran at 35.86 TFLOPS sustained on LINPACK and held the #1 spot for two and a half years.

The reaction in the United States — political, scientific, and architectural — is one of the most consequential moments in late HPC history. It directly funded the development of every American exascale machine that exists today.

This week is about that machine, why it won, and the response it triggered.

## What it was

- **Built**: 2001–2002, by **NEC** and Mitsubishi Heavy Industries, at Yokohama.
- **Cost**: ~$400M.
- **Purpose**: Earth-system simulation — global atmospheric and oceanic modeling at sub-10 km resolution, for climate research and disaster prediction.
- **Compute nodes**: 640 vector nodes.
- **Per-node**: 8 NEC SX-6-derived vector CPUs (each with a 16-pipe vector unit, 8 GFLOPS peak), 16 GB shared memory. So **64 GFLOPS peak per node**.
- **Total CPUs**: 5,120.
- **Aggregate peak**: 40.96 TFLOPS.
- **LINPACK sustained**: 35.86 TFLOPS — *87% of peak.* This number deserves a moment.
- **Interconnect**: a custom **single-stage crossbar** connecting all 640 nodes. 12.3 GB/s per node link, all-to-all, sustained. Power-hungry, expensive, and *fast*.
- **Building**: a dedicated three-story facility, ~3,250 m² of compute floor, with active seismic isolation and integrated cooling — the building was part of the architecture.

## What made the LINPACK number remarkable

87% of peak on LINPACK is *enormous*. Contemporary cluster machines typically hit 60–75% of peak on LINPACK; today's GPU-based exascale machines hit ~65–70%. The Earth Simulator's efficiency was a consequence of:

1. **Long vector registers**. NEC's 256-element vectors meant memory bandwidth was utilized at near-peak.
2. **Memory bandwidth that matched the compute**. Each node had 32 GB/s of memory bandwidth per CPU, sustained. Modern CPUs have a much higher compute-to-bandwidth ratio (the "memory wall"), so they spend a lot of cycles waiting on memory.
3. **The crossbar interconnect**. Every node could talk to every other at full bandwidth simultaneously, for collective operations. Cluster machines on multistage networks pay a contention tax that ES did not.

The "memory wall" — the growing gap between CPU compute throughput and memory bandwidth — has been the dominant trend in microprocessor design since 1995. The Earth Simulator was, in a sense, the last machine where compute throughput and memory bandwidth were balanced.

## What it ran

Real codes, not just LINPACK:

- **AFES** (atmospheric general circulation model). At ~10 km grid spacing globally, sustained 26.6 TFLOPS — the first time an Earth-system model ran at high resolution on real hardware.
- **OFES** (ocean general circulation model). Tens of teraflops sustained.
- **Plasma simulation, seismic-wave propagation, turbulence DNS** — multiple papers reporting sustained performance >50% of peak across diverse scientific domains.

The point: real applications, not just contrived benchmarks, ran at high sustained efficiency. ES was a productive scientific instrument, not a stunt. Many of the climate-modeling results that informed the IPCC AR4 report (2007) came off the Earth Simulator.

## The American reaction

The Earth Simulator's #1 finish in June 2002 prompted what came to be called the "**Computenik**" reaction (echoing the Soviet Sputnik launch of 1957). The DOE, NSF, and DARPA all launched response programs, with arguments along these lines:

> The United States has lost its leadership in high-end computing. We have allowed our entire HPC architecture path to be commodity microprocessor clusters, optimized for cost, not capability. The Japanese have shown that purpose-built vector machines can deliver multiples better real-application performance. We need to fund the development of the next generation of high-end systems explicitly.

The most consequential program that followed was DARPA's **High Productivity Computing Systems** (HPCS) program, launched in 2002:

- **Phase I (2002–2003)**: study contracts to Cray, IBM, HP, SGI, Sun.
- **Phase II (2004–2006)**: prototype contracts to Cray, IBM, Sun.
- **Phase III (2006–2010)**: production system contracts to Cray (resulting in **XT5/Jaguar** at ORNL) and IBM (resulting in **PERCS** / **Blue Waters** at NCSA).

HPCS was supposed to also produce next-generation programming languages — Cray's **Chapel**, IBM's **X10**, Sun's **Fortress**. Of these, only Chapel survived as an active open-source project; X10 was discontinued in the mid-2010s; Fortress was canceled when Sun was acquired by Oracle.

The hardware result, however, was concrete. **Jaguar** (ORNL, 2009) became #1, then was upgraded to **Titan** (2012) — the first GPU-accelerated #1 system. **Blue Waters** at NCSA (2013) was, after schedule slips, a Cray XE/XK system rather than IBM's original PERCS design. The HPCS program, even when its goals weren't all met, *paid for the development capacity* that produced every subsequent American exascale machine.

## What the Earth Simulator did *not* do

It did not cause vector supercomputers to win again, in the long run. By 2004 the Top500 #1 was IBM's BlueGene/L (cluster of low-power microprocessors), and from then on the vector model lost ground every year.

The reason is simple: NEC SX vector processors cost roughly 100× as much per FLOP as commodity microprocessors. The Earth Simulator's $400M procurement bought 35 TFLOPS sustained; ASCI Red Storm at Sandia in 2004 bought 36 TFLOPS sustained for ~$90M. Outside Japan, governments did not fund another vector machine of comparable scale. Inside Japan, the **Earth Simulator 2** (2009, 131 TFLOPS) and **ES3** (2015, 1.3 PFLOPS) followed, but neither was again the world's fastest.

What the Earth Simulator *did* do: it convinced the HPC community, durably, that:

1. **Per-application sustained performance, not peak FLOPS, is the figure of merit.** This led to the introduction of HPCG (High Performance Conjugate Gradient) in 2014 as a complementary benchmark to LINPACK. HPCG stresses memory bandwidth and irregular access — *exactly* what made ES fast and what cluster-of-microprocessors makes slow.
2. **Memory bandwidth and balance matter as much as raw FLOPS.** The path of HBM (high-bandwidth memory) integration in modern chips — A100, H100, MI300, Fugaku's A64FX — is in part a response to this lesson.
3. **Government investment in HPC architecture has compounding returns.** HPCS is one of the cleaner success stories.

The Earth Simulator's most important legacy might be that it made the metric "sustained on real applications" a permanent counterweight to the "peak FLOPS on LINPACK" headline number.

## How "supercomputer" diverges from "Cray's vision" — first signpost

The Earth Simulator was the *last* major machine that one could plausibly describe as in the direct lineage of the Cray-1: a centrally-engineered, custom-silicon vector machine, where the architectural unit of thought was a single fast pipeline operating on long vectors. After ES, the lineage *all* runs through clusters and accelerators, regardless of whether the per-element compute happens to look vector-shaped.

If you asked Seymour Cray what he thought a 2026 supercomputer should look like, the honest answer would be: "He would have enjoyed the engineering and disagreed with the architecture." The Cray-1 was a unified mind doing one thing very fast. Frontier is fifty thousand minds doing fifty thousand things in coordination. They both compute — but the *kind of object* they are is different.

We pick up that thread in Week 15.

## Lab — HPL vs. HPCG on your laptop

In `labs/12-hpl-hpcg/`, you build and run two benchmarks:

1. **HPL** — High-Performance LINPACK. Solves a dense linear system. Compute-bound, hits a high fraction of peak FLOPS.
2. **HPCG** — High-Performance Conjugate Gradient. Solves a sparse system. Memory-bandwidth-bound, irregular access, hits 1–5% of peak FLOPS on most modern systems.

You run both on your laptop and observe the ratio. Then we compare to the Top500-published HPL/HPCG ratios for major systems. The Earth Simulator would have hit ~30% of peak on HPCG; modern GPU systems hit closer to 1.5%. The contrast tells you why HPCG was introduced.

## Discussion questions

1. The Earth Simulator's 87% of peak on LINPACK is unmatched in the modern era. Pick a current Top500 system and find its HPL fraction. Why is the gap so large? Identify the architectural choices responsible.
2. The HPCS program funded development of three new languages (Chapel, X10, Fortress). None displaced Fortran/C/MPI. What conditions would have to be different for a "next-generation" HPC language to actually take hold? Is it a technical problem, an inertia problem, or a problem with the kind of organization that funds research languages?
3. The Earth Simulator's success was due to high memory bandwidth per FLOP. Modern GPUs have very high *aggregate* bandwidth (HBM3 at 3+ TB/s on H100), but extremely high FLOPS as well. The bytes-per-FLOP ratio has actually *decreased* over time. Find the bytes-per-FLOP ratio for an Earth Simulator node and an H100 GPU. Then think about which workloads run efficiently on each.

## Further reading

- Habata, S., Yokokawa, M. & Kitawaki, S. (2003). "The Earth Simulator system". *NEC Research & Development*. The primary technical paper.
- Yokokawa, M. et al. (2002). "Performance evaluation of the Earth Simulator". *Proc. SC02*. Application performance results.
- Dongarra, J. (2002). "The Earth Simulator system: A wake-up call". A widely circulated commentary at the time of the announcement.
- Lazowska, E. & Patterson, D. (2005). "Computing research: A looming crisis". *CACM*. Part of the post-ES policy argument.
- Top500 / HPCG list (top500.org/lists/hpcg). Updated each year.
