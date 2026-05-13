# Week 5 — Japan: NEC SX, Fujitsu VP, Hitachi S-Series

## Where we are in 2026

Long-vector architectures — vector lengths of 256 or longer, with deep multi-pipe execution — are not a Cray invention. From 1982 through the mid-2000s, Japanese vendors (NEC, Fujitsu, Hitachi) built vector machines that often *exceeded* Cray's per-processor performance, used different architectural choices, and ran a parallel software ecosystem. They produced the Earth Simulator (2002), which knocked the United States off the top of the Top500 and triggered a multi-billion-dollar policy response.

If you only learn the American story you miss half of how vector computing actually evolved. This week is the other half.

## Why a parallel ecosystem existed

Three forces:

1. **MITI** (Japan's Ministry of International Trade and Industry) ran the National Superspeed Computer Project from 1981 to 1989, funding NEC, Fujitsu, and Hitachi to develop competitive supercomputers explicitly to challenge Cray Research.
2. **Trade tensions** made imports of US supercomputers into Japanese government and academic sites politically charged. NEC, Fujitsu, and Hitachi had a captive home market.
3. **Genuine technical divergence**: the Japanese designs were not Cray clones. They used different vector-register strategies, different pipe counts, different memory architectures.

## Fujitsu VP-200 (1982)

- **Clock**: 7.5 ns (133 MHz). Faster than Cray-1.
- **Vector registers**: dynamically reconfigurable — a 64KB register file the programmer could partition as 8×1024 or 16×512 or 32×256 elements depending on workload.
- **Peak**: 533 MFLOPS — three to four times the Cray-1.
- **Cooling**: Air-cooled with refrigerated cabinets. No Freon, no Fluorinert.

The reconfigurable register file was the first major divergence from the Cray model. Cray-1 had a fixed 8×64 layout. Fujitsu argued: workloads have different vector-length sweet spots, and the compiler should pick. The VP-200 sold well in Japan and Europe and competed seriously with the X-MP on per-processor performance, though it was a uniprocessor and could not match X-MP/4 aggregate throughput.

## Hitachi S-810 (1983)

- **Two parallel pipelines per CPU**, each of which was a multi-pipe vector unit. So one instruction could produce up to *four* results per cycle (Cray-1 produced one, X-MP per-CPU produced two via chaining).
- **Peak**: 630 MFLOPS.
- **Memory**: highly interleaved, with explicit vector "stride" instructions that handled non-unit-stride loads at full bandwidth (a chronic Cray weakness).

The S-810 introduced the idea of **multi-pipe vector units**: rather than a single vector pipeline producing one element per cycle, run multiple parallel pipelines and produce N elements per cycle. The trade-off is that each pipe needs its own port to memory and its own slice of the vector register file. Hitachi made it work because they were willing to spend more silicon per CPU than Cray was. NEC took this strategy further than anyone.

## NEC SX-2 (1985): the multi-pipe extreme

- **Sixteen parallel arithmetic pipelines** in one CPU, organized as four "sets" of four (add/multiply/divide/etc).
- **Clock**: 6 ns (167 MHz).
- **Peak**: 1.3 GFLOPS — a single CPU at near-Y-MP-aggregate throughput, three years before Y-MP shipped.
- **Vector length**: long. Up to 256 elements per register, with strip-mining in hardware.

NEC's bet was clear: rather than build many CPUs sharing a memory (the X-MP/Y-MP path), build *one* enormous CPU with so much internal parallelism that it ran a single-threaded vector program at scary speed. This bet paid off for NEC for *twenty years* — from SX-2 in 1985 through SX-9 in 2008, NEC consistently held the title of "fastest single processor for vector code" against all comers.

## SX-3, SX-4, SX-5: the dynasty

- **SX-3 (1990)**: 4 CPUs sharing memory, 16-pipe per CPU, 5.5 GFLOPS aggregate. It predated the Top500 list and was a major single-node vector milestone, but it was not a Top500 #1 system.
- **SX-4 (1995)**: 32 CPUs, 8 GFLOPS per CPU, 256 GFLOPS peak. Competitive with everything from Cray.
- **SX-5 (1998)**: 16 CPUs per node, multiple nodes networked — the architectural template that became the Earth Simulator.

For most of the 1990s, an NEC SX was the fastest *single processor* in the world. American codes that needed long-vector throughput — climate models particularly — ran significantly faster on an NEC than on a Cray T3E or an SGI Origin. The US national labs declined to buy them, primarily for political reasons (a 1997 anti-dumping ruling effectively imposed a 454% tariff on NEC SX-4 imports into the US). Universities outside the US bought them in volume: ECMWF in the UK, DKRZ in Germany, the Australian Bureau of Meteorology, Météo-France.

## What the code looked like

The dirty secret: Fortran was Fortran. Vector code that ran on a Cray Y-MP would compile and run on an NEC SX-4. The compilers were different (NEC's `f90`/`sxf90`, Fujitsu's `frt`, Hitachi's `xf77`), the directive vocabulary was different, and the *performance characteristics* were dramatically different — but the source-level model was the same: write Fortran loops, decorate with vendor directives, ship.

Where a Y-MP wanted vector length 64 to be efficient, an NEC SX wanted **256** or more to amortize the wider pipe count. Code tuned for one machine often ran sub-optimally on the other:

```fortran
!CDIR LONGLOOP             ! NEC SX: trip count >> 256, deep vector profitable
!DIR$ SHORTLOOP            ! Cray: trip count fits in 64-element register, skip cleanup
      DO I = 1, N
        ...
```

This is a real complication: the user-visible programming model was uniform-ish across vendors, but the *performance portability* was poor. Codes optimized for NEC ran well on NEC; the same source compiled for Cray was 30% off peak.

This problem — performance portability across vector ISAs — has not gone away. Modern OpenMP and Kokkos and SYCL exist precisely to manage it across CPU SIMD widths and GPU architectures.

## The Earth Simulator (2002): vectors strike back

This was the apex of the long-vector approach. We give it a full chapter (Week 12), but you should know now what it was:

- 640 nodes, each with 8 NEC SX-6-derived vector CPUs. **5,120 CPUs total**.
- **35.86 TFLOPS** sustained on LINPACK.
- Held Top500 #1 from June 2002 to June 2004.
- Did so by being *almost 5× faster* than the previous #1 by LINPACK Rmax: 35.86 TFLOPS versus ASCI White's 7.226 TFLOPS on the June 2002 Top500 list.

It was the last machine where a vector architecture decisively led the world. After 2004 the cluster-and-accelerator era took over. The Earth Simulator's success fed a broader US "Computenik" policy reaction. DARPA's **High Productivity Computing Systems** (HPCS) program was the most visible response program, funding Cray, IBM, Sun, and others; its direct outputs include Chapel, IBM PERCS work, and Cray's Cascade/XMT line, while later Cray XT/XE/XK systems such as Jaguar and Titan drew on overlapping vendor capacity rather than being simple one-to-one HPCS products.

## Why the Japanese vector ecosystem persisted longer than Cray's

Three reasons:

1. **Government procurement.** JMA (weather), MEXT (research), domestic universities — all kept buying.
2. **Climate modeling.** The single most demanding scientific workload of the era was atmospheric simulation. It vectorized beautifully and parallelized poorly. NEC's long-vector approach was perfectly suited; clusters of microprocessors were not. ECMWF stayed on NEC and Cray X-series until 2014.
3. **Genuine technical merit.** Multi-pipe long-vector designs *are* good for the workload. They lost to clusters not because they were technically inferior but because clusters were *cheaper per FLOP* by an order of magnitude, on a $/FLOP curve dominated by the volume economics of microprocessors.

The NEC SX line continued through SX-9 (2008), SX-ACE (2013), and finally **SX-Aurora TSUBASA** (2018). The Aurora TSUBASA is fascinating — it's an NEC vector engine on a PCIe card, treating a host x86 server the way GPUs do. It is, in essence, a 21st-century pure-vector accelerator. Few outside of Japan have ever heard of it.

## Lab — Long vectors vs. short vectors

In `labs/05-vector-length/`, you run a NumPy SAXPY-style benchmark across a sweep of vector lengths, then focus on three reference regions:
- `N = 64` (Cray-1 sweet spot)
- `N = 256` (NEC SX sweet spot)
- `N = 1_000_000` (modern memory-bound)

You'll see the fixed-overhead-per-call versus per-element-cost trade-off in action. The lab is intentionally a portable Python/NumPy proxy: the modern low-level story is "many short SIMD vectors, fed by cache and prefetch", not "one long vector", but the measured curve still shows the trade-off that made Cray and NEC choose different vector lengths.

## Discussion questions

1. NEC's multi-pipe approach (16 parallel arithmetic pipes per CPU in 1985) is structurally similar to a modern GPU's SM (32-wide SIMT, multiple SMs per chip). Why did this approach lose in CPUs (where SIMD widths topped out at 8–16 elements) but win in GPUs (where it kept growing)?
2. Performance-portable vector programming was already a problem in 1990. How does ARM SVE (with its "vector-length agnostic" programming model) address this problem? Does it actually solve it, or does it just give the compiler a different set of choices?
3. The 1997 anti-dumping tariff on NEC SX-4 imports was politically motivated but had real architectural consequences: US national labs developed long expertise in clusters and short consumer-CPU-derived SIMD, not long-vector machines. What current US export-control policies (e.g., NVIDIA H100 export to China) might have similar long-term architectural side effects?

## Further reading

- Watanabe, T. (1987). ["Architecture and performance of the NEC SX-2"](https://doi.org/10.1016/0167-8191(87)90021-4). *Parallel Computing* 5:247–255. NEC's own description.
- Miura, K. & Uchida, K. (1983). "Fujitsu VP-100/200: Vector machines for scientific computation". *Proc. Supercomputing*.
- Habata, S., Yokokawa, M. & Kitawaki, S. (2003). ["The Earth Simulator system"](https://www.eecg.toronto.edu/~amza/ece1747h/papers/earth-sim-nec.pdf). *NEC Research & Development*.
- Reed, D. & Dongarra, J. (2015). ["Exascale computing and big data"](https://doi.org/10.1145/2699414). *CACM*. Touches on the policy fallout from the Earth Simulator era.
