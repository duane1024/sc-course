# Week 11 — ASCI, ASC, and BlueGene: When Power Became the Constraint

## Where we are in 2026

Modern supercomputers are power-limited. The capital cost of a Frontier-class machine is still enormous, but site power and lifetime operating cost now shape the architecture as strongly as procurement price does. Site selection is driven by access to cheap and reliable electrical power. Cooling design — direct liquid cooling, immersion, two-phase fluorocarbon — is the active research front. The reason all of this is true is a structural cliff that arrived around 2004 and was first navigated, brilliantly, by IBM's BlueGene project. Before that, the DOE's ASCI program drove the scale; after BlueGene, every supercomputer designer learned to count joules first and FLOPS second.

This week is the story of those two arcs — how the labs drove scale up, and how power forced architecture to change.

## ASCI / ASC: simulating what we no longer test

The **Comprehensive Test Ban Treaty** (signed 1996, never ratified by the US Senate but observed in practice) ended underground nuclear testing in the United States after September 1992. The US weapons complex needed an alternative way to certify the safety, security, and reliability of the stockpile: large-scale physical simulation. The DOE's response was the **Accelerated Strategic Computing Initiative** (ASCI, 1995–2005, renamed the **Advanced Simulation and Computing program** (ASC) thereafter).

ASCI's premise was that to credibly simulate weapons physics with the resolution required for stockpile certification, you needed compute scale increases of multiple orders of magnitude over what existed in 1995, on a roughly five-year cadence. That meant funding the construction of machines that did not yet exist, with explicit DOE/lab/vendor co-design. ASCI is the most consequential procurement program in HPC history.

The roster:

| Year | Machine | Site | Architecture | Peak |
|------|---------|------|--------------|------|
| 1997 | ASCI Red | Sandia | Intel Pentium Pro/II MPP | 1.8 TFLOPS |
| 1998 | ASCI Blue Pacific | LLNL | IBM SP2 (PowerPC 604e) | 3.9 TFLOPS |
| 1998 | ASCI Blue Mountain | LANL | SGI Origin 2000 | 3 TFLOPS |
| 2000 | ASCI White | LLNL | IBM SP (Power3) | 12.3 TFLOPS |
| 2002 | ASCI Q | LANL | HP AlphaServer SC | 20 TFLOPS |
| 2005 | ASC Purple | LLNL | IBM SP (Power5) | 92 TFLOPS |
| 2005 | BlueGene/L | LLNL | IBM BG/L | 596 TFLOPS |
| 2008 | Roadrunner | LANL | AMD + Cell BE | 1.45 PFLOPS |
| 2012 | Sequoia | LLNL | IBM BG/Q | 20 PFLOPS |
| 2018 | Sierra | LLNL | IBM Power9 + NVIDIA Volta | 125 PFLOPS |
| 2024 | El Capitan | LLNL | AMD MI300A APUs | 1.74 EFLOPS |

**Sources for the table.** Peak figures are *Rpeak* from the Top500 list of the relevant June or November (whichever was closest to acceptance), except where noted. Per-machine primary citations:

- **ASCI Red** (Sandia, 1997): Mattson & Henderson, "ASCI Red: Experiences and lessons learned" (SC97); Foster et al. (2005).
- **ASCI Blue Pacific** (LLNL, 1998): LLNL Computing user documentation; Top500 November 1998.
- **ASCI Blue Mountain** (LANL, 1998): LANL ASCI program reports; Top500 November 1998.
- **ASCI White** (LLNL, 2000): Top500 November 2000.
- **ASCI Q** (LANL, 2002): Top500 November 2002; HP AlphaServer SC product documentation.
- **ASC Purple** (LLNL, 2005): IBM Power5 system documentation; Top500 November 2005.
- **BlueGene/L** (LLNL, 2005): Adiga et al. (2002) for the architecture overview; Top500 November 2005 for the 596 TFLOPS Rmax/Rpeak figures.
- **Roadrunner** (LANL, 2008): Barker, K. et al. (2008), "Entering the petaflop era: The architecture and performance of Roadrunner" (SC08); Top500 June 2008 for the 1.026 PFLOPS Rmax.
- **Sequoia** (LLNL, 2012): IBM BG/Q architecture papers; Top500 June 2012.
- **Sierra** (LLNL, 2018): IBM POWER9 + NVIDIA Volta system documentation; Top500 November 2018.
- **El Capitan** (LLNL, 2024): Garcia et al. (2022), "El Capitan: An advanced architecture exascale system at LLNL" (SC22); Top500 November 2024 list for the debut figures, November 2025 list for updated HPL numbers.

The ASC roster reads as a cross-section of the architectural evolution we're tracking in this course. The labs paid for, helped design, and ran every major architectural shift: pure MIMD MPP (Red), big SMP node clusters (White, Purple), low-power MPP at extreme scale (BlueGene), the first heterogeneous-accelerated supercomputer (Roadrunner), GPU-accelerated nodes (Sierra), APU-integrated exascale (El Capitan).

## Why scale ran into power around 2004

For three decades, **Dennard scaling** had given the industry a free lunch: as CMOS feature size shrank, voltage and current per transistor scaled down with it, so power per transistor shrank. Doubling transistor count per generation didn't double power. You got more compute *and* it ran cooler.

Around 2004, Dennard scaling collapsed. Voltage stopped scaling because of leakage current — at smaller feature sizes, sub-threshold leakage became significant, and dropping voltage further made transistors unreliable. From ~2004 onward, doubling transistor count *did* roughly double power. Frequency scaling stopped — chip clocks plateaued near 3–4 GHz. (Look at any single-core CPU clock chart: 2004 is the inflection point.)

This was the end of the "free lunch". In one decade you went from "buy a faster CPU and your code gets faster" to "buy a wider/parallel CPU and rewrite your code to use it". The HPC industry felt this first because it was already at the bleeding edge of power and cooling.

## BlueGene/L (2004): the response

IBM's response to the power cliff, designed at Yorktown Heights and Rochester from ~1999, productized at Lawrence Livermore from 2004. The design philosophy was a deliberate inversion:

> Instead of fewer, faster, hotter cores, build *vastly more, slower, cooler* cores.

- **Compute nodes / processors**: 65,536 compute nodes, each with two 700 MHz PowerPC 440 processors: 131,072 processors total. Compare to ASCI Q's 8,192 1.25 GHz Alpha processors — *many more processors, half the clock*.
- **Per-node power**: about 17 watts per node (with 2 cores). Total system: ~1.5 MW for 596 TFLOPS peak.
- **Compare to ASCI White**: 12.3 TFLOPS peak at 1.7 MW (~7 MFLOPS/W). BlueGene/L: roughly 596 TFLOPS peak at 1.5 MW (~400 MFLOPS/W). **About a 50× efficiency improvement.**
- **Interconnect**: a 3D torus for nearest-neighbor (the natural fit for physics codes), plus a separate global tree network for collectives, plus a separate barrier network for synchronization. *Three* dedicated networks, each optimized for its workload.
- **OS**: Compute Node Kernel (CNK), a stripped microkernel — only 5 MB of memory footprint. No demand paging, no signals, no fork. (Echo of Paragon.)

BlueGene/L was Top500 #1 from November 2004 to June 2008, the longest reign of any single architecture. It also dominated the **Green500** (the "FLOPS per watt" ranking) — at the time, BG/L systems were 5× more efficient than runners-up. *Sources for the BG/L specifications above: Adiga et al. (2002), "An overview of the BlueGene/L supercomputer," Proc. SC02; LLNL "BlueGene/L" historic machine page; Top500 and Green500 lists, November 2004 – June 2008.*

The BG line continued: **BlueGene/P** (2007, 850 MHz, 4-core PowerPC 450), and **BlueGene/Q** (2012, IBM A2 cores, 16-core, 1.6 GHz, with hardware transactional memory — Sequoia at LLNL hit 20 PFLOPS at 7.9 MW). *Sources: IBM BG/P and BG/Q system architecture papers; Top500 entries for Intrepid (ANL, BG/P) and Sequoia/Mira (LLNL/ANL, BG/Q).*

## What programming a BlueGene was like

If you knew MPI, you could program BlueGene. The compute-node OS exposed enough of POSIX to run MPI programs directly. The complications were:

1. **Node memory was small.** BG/L had 256 MB or 512 MB per node (two cores sharing). You could not fit a fat code onto a single node. *Domain decomposition was forced* — you had to split your problem across many nodes because no single node had enough memory to hold it.
2. **Node single-thread performance was modest.** A 700 MHz PPC 440 was about as fast as a Pentium III. If your code didn't scale to many ranks, you were sad.
3. **Virtual node mode.** On BG/Q (and back-ported to BG/P) you could run more MPI ranks than physical CPU cores by oversubscribing, exposing the chip's hardware multithreading.

The BlueGene project also pushed early adoption of **MPI + OpenMP hybrid** — one MPI rank per node, OpenMP threads inside the node sharing memory. This pattern then became standard on every multi-core HPC system in the 2010s.

The **MPI source code** of an LLNL stockpile-stewardship simulation didn't change much going from ASCI White to BG/L to Sequoia. The configuration changed (more ranks, smaller per-rank chunks), some on-node parallelism was added with OpenMP, but the algorithmic structure was preserved. This is why ASCI's enormous investments in physics codes paid off: the codes outlived the machines.

## Why the BG line ended

IBM stopped the BlueGene line after BG/Q in 2012. The reasons:

1. **GPUs ate the FLOPS-per-watt crown.** A 2012 NVIDIA Kepler K20X delivered roughly 5–6 GFLOPS/W in FP64 by peak-spec arithmetic, while BG/Q systems were around 2–3 GFLOPS/W at the system level. The custom-low-power-PowerPC bet stopped being competitive once general-purpose accelerators reached comparable or better efficiency at much higher node throughput.
2. **Single-thread performance mattered for the codes that didn't parallelize.** Some workloads, especially in materials science and graph analytics, didn't have the embarrassingly-parallel structure that BG was tuned for. Those workloads needed faster cores.
3. **Aurora**, originally planned as an Intel Xeon Phi BlueGene successor, was delayed and redesigned several times.
4. **Internal IBM strategy** moved toward POWER + GPU, which became Summit (ORNL, 2018) and Sierra (LLNL, 2018).

But the BG architectural lessons stuck. *Fugaku* (RIKEN, 2020), built around the Fujitsu A64FX ARM chip, is a spiritual descendant — many simple cores, vector units, no GPUs, designed for power efficiency and tight system integration. It hit Top500 #1 in 2020.

## Power as the design driver, post-BG

After BG, every major supercomputer design starts with a power budget — typically 20–40 MW for an exascale system — and works backward to architecture. *That* is the structural shift. Compare:

- **Cray X-MP/4** (1985): 800 MFLOPS at ~125 kW. ~6 MFLOPS/W.
- **ASCI White** (2000): 12 TFLOPS at 1.7 MW. ~7 MFLOPS/W. (A modest improvement over Cray-era system-level efficiency, but at much larger scale.)
- **BlueGene/Q Sequoia** (2012): 20 PFLOPS at 7.9 MW. ~2.5 GFLOPS/W. (Factor of 350× over ASCI White — the slope is dramatic.)
- **Frontier** (2022): 1.1 EFLOPS at 21 MW. **52 GFLOPS/W**.
- **El Capitan** (2024): 1.8 EFLOPS-class HPL performance at about 30 MW. Roughly **60 GFLOPS/W** on the current Top500/Green500-style HPL metric.

Power efficiency improvement, on the curve, has been *faster* than raw FLOPS improvement for the past two decades — because raw FLOPS isn't the constraint, joules are. Every architectural decision in a modern HPC system is in service of this constraint.

The same dynamic also reshaped what "performance" meant. From the mid-2000s on, the field needed a benchmark that measured *delivered* memory bandwidth, not peak FLOPS. The canonical answer is **STREAM** (McCalpin, 1995, University of Virginia) — four tiny kernels (copy, scale, add, triad) sized far beyond any cache, reporting sustained bytes-per-second. STREAM is the bandwidth equivalent of LINPACK and is the right number to look at first when reasoning about post-Dennard architectures. We'll see it return in the Roofline discussion in Week 15.

## Lab — Profile your laptop's power

In `labs/11-power-profile/`, you measure the energy cost of three SAXPY implementations on your laptop:

1. Naïve Python loop.
2. NumPy.
3. C with OpenMP and AVX.

You time them, then read your laptop's power draw (via `powermetrics` on macOS, `powerstat` or `s-tui` on Linux, or `intel-power-gadget` on older systems). You compute joules per FLOP for each. The ratios you see — typically 2–3 orders of magnitude across the three implementations — are the same ratios driving every architectural decision in modern HPC.

## Discussion questions

1. BlueGene/L's design philosophy — many small cores, slow clock, integrated network — is broadly the same as a modern data-parallel GPU. Both are responses to the post-Dennard power cliff. What did BG do that GPUs didn't? Why did GPU-style win for general-purpose HPC while BG-style stayed at the labs?
2. The DOE's ASCI program *paid for* architectural development that benefited the whole industry: every major HPC vendor's codebase has DOE-funded improvements in it. Is this a healthy industrial policy? Compare to Japan's Earth Simulator (next week) or China's exascale program (Sunway, Tianhe).
3. ASCI codes have lifespans of decades. The hardware they run on has lifespans of years. The ratio is roughly 10:1. What does this tell you about the tradeoff between optimizing for current hardware (e.g., writing CUDA-specific code) and writing portable code (e.g., MPI + OpenMP + standard C++)?

## Further reading

- Adiga, N.R. et al. (2002). "An overview of the BlueGene/L supercomputer". *Proc. SC02*. The IBM design overview.
- Bhatele, A. et al. (2013). "Identifying the culprits behind network congestion". *Proc. SC13*. Real-world experience with BG/Q networks; teaches a lot about why interconnect matters.
- Top500 lists 2004–2012, watching the Green500 emerge alongside.
- Foster, I. et al. (2005). "ASCI Red: The first TFLOPS computer at Sandia". *IEEE Computer*. Includes the full history of the program through ASC Purple.
- The DOE's "Exascale Computing Project" (ECP) reports, 2016 onward — the formal successor to ASCI/ASC.
