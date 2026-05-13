# Week 6 — The Vector Wall: ETA-10, Cray-3, and the Death of Bespoke

## Where we are in 2026

Around 1990, the bespoke-ECL-vector-supercomputer business model — the model Seymour Cray invented and that ran the industry for fifteen years — broke. It did not break because vector computing was wrong (we use vector computing more than ever), and not because Cray's engineering was deficient (the Cray-3 was a technical marvel). It broke because *commodity microprocessor economics* outran custom logic. Knowing the precise mechanics of that break is necessary to understand every architectural decision since.

This week is the autopsy.

## Background: the trend lines crossing

In 1976, a Cray-1 at 80 MHz was about 80× faster on scientific code than a contemporary minicomputer. By 1989, the gap had narrowed dramatically. A few data points:

| Year | Top vector machine | Top microprocessor | Vector / micro ratio |
|------|--------------------|--------------------|----------------------|
| 1976 | Cray-1 @ 80 MHz, 160 MFLOPS | Intel 8080 @ 2 MHz, ~0.05 MFLOPS | ~3000× |
| 1985 | Cray X-MP/4 @ ~940 MFLOPS | Motorola 68020 @ 16 MHz, ~0.5 MFLOPS | ~1900× |
| 1990 | Cray Y-MP/8 @ ~2.7 GFLOPS | MIPS R3000 @ 33 MHz, ~10 MFLOPS | ~270× |
| 1993 | Cray C90/16 @ ~16 GFLOPS | DEC Alpha 21064 @ 200 MHz, ~120 MFLOPS | ~133× |
| 1996 | Cray T90/32 @ ~58 GFLOPS | DEC Alpha 21164 @ 500 MHz, ~1 GFLOPS | ~58× |

**Sources for the table.** Cray peak FP64 figures are from Cray Research product literature, collected with Russell (1978) for the Cray-1, Chen (1984) for the X-MP, and the Y-MP/C90/T90 hardware reference manuals on bitsavers.org. Microprocessor LINPACK and peak-FLOPS estimates are from Dongarra's *Performance of Various Computers Using Standard Linear Equations Software* report (continuous since 1979; netlib.org/benchmark/performance.ps), the canonical source for per-CPU performance comparisons in this era. Per-microprocessor numbers are LINPACK *n* = 100 results where available, peak FP throughput otherwise; the 8080 figure is software-emulated single-precision throughput (the 8080 had no FPU) and is included for shape, not precision. The right-hand "ratio" column compares aggregate vector-machine throughput to single-microprocessor performance and should be read as an order-of-magnitude indicator, not a head-to-head benchmark.

The ratio is collapsing because microprocessors are doubling every 18 months (Moore's Law plus Dennard scaling) while bespoke ECL vector machines are improving by maybe 50% per generation, and shipping new generations only every 3–4 years. The arithmetic is pitiless: an exponential beats a slow exponential, and the gap is closing.

In 1989 Eugene Brooks of Lawrence Livermore wrote an essay titled **"Attack of the Killer Micros"**. The argument: in five years, microprocessor performance will catch up with bespoke supercomputer per-CPU performance, and once it does, the per-FLOP cost advantage of clusters of micros is overwhelming. Bespoke vector machines will be reduced to a niche product.

He was right. The argument was, by then, already widely shared inside the industry. The two bespoke-vector-supercomputer attempts of 1987–1995 — ETA Systems and Cray Computer Corporation — were the last attempts to outrun the trend, and both failed for reasons baked into the architecture choice.

## ETA-10 (1987): liquid nitrogen wasn't enough

ETA Systems was a 1983 spinoff of Control Data Corporation, with a brief to build the successor to the **CDC Cyber 205** (1981). The Cyber 205 itself was the successor to the **CDC STAR-100** — both memory-to-memory vector machines that Cray had bested with the Cray-1.

The ETA-10 (1987) was their answer: a multi-CPU vector machine using **CMOS** (not ECL!), cooled to 77 K with **liquid nitrogen** (not Freon, not Fluorinert) to reduce CMOS gate delays.

- **8 vector CPUs**, shared memory.
- **Clock**: 7 ns (143 MHz) at 77 K.
- **Peak**: 10 GFLOPS aggregate — the fastest machine of its era at announcement.
- **Memory**: 256 MW (2 GB).

CMOS at 77 K was a fascinating bet. CMOS dissipates much less power than ECL, scales better with feature size, and has natural manufacturing volume from the rest of the chip industry. Cooling it cryogenically (instead of pushing ECL with Freon) was elegant.

It didn't work. The ETA-10 had three killing problems:

1. **Software immaturity**. ETA shipped its own variant of UNIX called EOS, which was buggy and incompatible with anything customers had. The Cyber 205's compilers and software were not reused. Big customers (NASA, the labs) wanted Cray-compatible tools and got something else.
2. **Low yield on the cryogenic cooling**. The cryogenic units were complex, prone to failure, and hard to service.
3. **The benchmarks didn't reflect real applications**. ETA's published benchmarks were peak-oriented and short-vector codes ran nowhere near peak.

Control Data shut down ETA Systems in **April 1989**, eighteen months after first delivery, having shipped fewer than 30 units. CDC itself spiraled out of the supercomputer business shortly after.

## Cray-3 (1993): GaAs at any cost

After the X-MP shipped in 1982, Seymour Cray was eased out of the X-MP/Y-MP development path inside Cray Research. By 1989, his Cray-3 effort was so different from the company's mainstream that he split off to form **Cray Computer Corporation** (CCC) in Colorado Springs, taking the Cray-3 and Cray-4 projects with him.

The Cray-3 was Seymour Cray's bet that **gallium arsenide** (GaAs), not silicon, was the future of fast computing.

- **Logic technology**: GaAs gate arrays, custom-designed.
- **Clock**: 2 ns (500 MHz) — *six times* faster than the Y-MP.
- **CPUs**: up to 16 vector processors sharing memory.
- **Memory**: 128–256 MW.
- **Peak**: ~16 GFLOPS aggregate.
- **Cooling**: Fluorinert immersion, like the Cray-2, but more so.

The Cray-3 was a *real machine*. It worked. One was delivered, in 1993, to the National Center for Atmospheric Research (NCAR), which used it for some months and then sent it back when funding for it disappeared. NCAR was the only Cray-3 customer. Cray Computer Corporation declared bankruptcy in **March 1995**. There was a Cray-4 design (4 GFLOPS per CPU at 1 GHz) that never shipped. Seymour Cray died in October 1996 in a car accident in Colorado Springs, age 71.

## Why GaAs and exotic cooling lost

The Cray-3 was technically successful. It was also obsolete the day it shipped, and not because Cray Computer Corporation managed it badly. The reasons were structural:

1. **GaAs lost the volume war.** GaAs was real, and faster than silicon at gate level, but it had no manufacturing ecosystem outside of military and RF chips. CMOS had millions of unit volumes from PCs, workstations, and the mainframe industry. Tooling, design rules, and yield improvements compounded for CMOS for thirty years. By 1993 CMOS at 0.6 µm beat GaAs at the gate-delay numbers Seymour had bet on.
2. **The clock advantage was illusory at the system level.** A Cray-3 at 500 MHz had to feed 16 CPUs from a shared memory. The memory subsystem couldn't keep up at the clock rate the processor wanted. Sustained performance on real applications was *not* 6× the Y-MP — often it was 1.5×, while costing 4× as much.
3. **Microprocessors were closing.** A single 200 MHz DEC Alpha 21064 in 1993 hit ~120 MFLOPS sustained. A Cray-3 CPU hit maybe 600 MFLOPS sustained. So one Cray-3 CPU was 5× a single Alpha — but a 1024-node cluster of Alphas (totally feasible by 1995) was 60× a Cray-3 in aggregate, for half the price. Customers who needed throughput, not single-job latency, did the math.

## The architectural epitaph

Looking back, the bespoke-ECL/GaAs vector supercomputer era ended because **performance per dollar drove the market more than performance per CPU**. Once microprocessors got within an order of magnitude per-CPU, the volume cost advantage of clusters became insurmountable for any workload that could be parallelized.

Workloads that could *not* be parallelized — and there are real ones, mostly the fluid simulations and climate models we discussed last week — kept buying NEC SX vector machines into the 2010s. NEC could afford to keep going because they had a captive home market and an integrated chip-design-to-system pipeline. Cray Research (which became part of SGI in 1996, then independent again, then HPE in 2019) pivoted to clusters of commodity processors tied together with custom interconnect — a different business and a different architecture.

## What the code didn't change

A peculiar thing: nothing about the **Fortran source code** of a typical scientific application changed during this transition. A weather model written for a Cray X-MP in 1985 could be (and was) recompiled for an SGI Origin 2000 in 1998, and recompiled again for a Cray T3E, and recompiled again for an IBM SP2 cluster, and recompiled *yet again* for a Beowulf-style commodity cluster. The hardware revolution at the bottom of the stack was largely invisible at the source level — the *programming model* was preserved.

What changed was *between* the Fortran source and the machine: the compiler stopped emitting CAL-style chained vector instructions and started emitting microprocessor SIMD instructions, while the parallelism model shifted from microtasking directives to MPI message passing (Week 9). This is a recurring theme: programming models persist longer than hardware, and the *job* of compilers gets harder every era.

## Lab — Replay the killer-micro crossover

In `labs/06-killer-micros/`, you build a small benchmark harness that runs SAXPY-of-different-sizes on:
- A pure-Python loop (proxy for unoptimized scalar code).
- NumPy (proxy for compiled scalar code with auto-vectorization).
- NumPy with explicit BLAS calls (proxy for hand-tuned vector library).
- An optional compiled C/SIMD comparison using the Era 2 vectorized C example.

Then plot the trend the same way Eugene Brooks would have in 1989. The point: the "killer micro" effect is happening *again* right now between CPU and GPU, and the curves look the same.

## Discussion questions

1. Eugene Brooks predicted the killer micros would win five years before they did. What current architectural prediction (e.g., "GPU dominance will end at exascale", "RISC-V will displace x86 in HPC", "optical interconnects will replace electrical at the rack level") has the same shape — observable trend lines, contested timing, technical and economic causality intertwined?
2. Cray-3 used GaAs for one reason: gate delay. Modern chips use silicon for ten reasons: gate delay, density, power, manufacturing volume, yield, thermal, SRAM compatibility, FinFET physics, EUV lithography, design tooling. What does the *count* of reasons tell you about why exotic device technologies (carbon nanotubes, spintronics, photonic compute) keep failing to displace silicon despite being technically superior on one or two axes?
3. The Cray-3 shipped functional but commercially dead. Find another example in the history of computing of a "technically working but economically obsolete" system. What's the common thread?

## Further reading

- Brooks, E. (1989). "Attack of the killer micros". Lawrence Livermore National Laboratory. The original talk transcript is widely circulated as a memo; see also coverage in *HPCwire*'s 2009 retrospective.
- Schneck, P. (1987). [*Supercomputer Architecture*](https://doi.org/10.1007/978-1-4615-7957-1). Includes contemporary analysis of the Cyber 205, Cray X-MP, and ETA-10.
- Wadsworth, A. (1996). "Cray Computer Corporation Chronology". Personal account by a former CCC engineer; widely referenced.
- Markoff, J. (1996). ["Seymour Cray, Computer Industry Pioneer And Father of Supercomputer, Dies at 71"](https://pages.cs.wisc.edu/~bezenek/cray.html). *NYT*, October 6.
- For the macro picture: Hennessy & Patterson, [*Computer Architecture: A Quantitative Approach*](https://shop.elsevier.com/books/computer-architecture/hennessy/978-0-443-15406-5), chapter 1 ("Trends in Technology") in any edition since 1995, where the killer-micros argument is given quantitative form.
