# Week 4 — X-MP, Cray-2, Y-MP: When Vectors Met Multiprocessing

## Where we are in 2026

Every multi-core CPU you have ever programmed with OpenMP is using a programming model that was invented at Cray Research between 1982 and 1988, on machines that combined vector processing with shared-memory multiprocessing. The directives, the fork-join semantics, the contention management, the false-sharing problems, the autoparallelization — all of it was working production technology a decade before OpenMP was standardized in 1997.

This week we look at the three machines that built that programming model: the **Cray X-MP**, the **Cray-2**, and the **Cray Y-MP**.

## The split at Cray Research

By 1980, Seymour Cray and Cray Research had a problem: Seymour wanted to build an even-faster single-processor machine (which would become the Cray-2), and the company needed a near-term follow-on to the Cray-1 that customers could order *now*. Cray Research's compromise was to let **Steve Chen** lead a parallel design effort — the Cray-1 successor that became the X-MP. The two projects ran simultaneously. They produced different machines aimed at different customers, and one of them turned out to be much more successful than the other.

## Cray X-MP (1982): two Cray-1s sharing memory

Steve Chen's design philosophy: take the Cray-1, make it 50% faster per processor, and give it 2 (later 4) of those processors sharing one memory.

- **Clock**: 105 MHz, then 118 MHz on the X-MP/4, then 138 MHz on the X-MP/48.
- **Processors**: 2 (X-MP/22), 4 (X-MP/48). All sharing one main memory.
- **Memory**: Up to 16 MW (128 MB), 32-way interleaved. *Crucially*, **multiple memory ports per CPU** — every X-MP CPU could simultaneously execute two vector loads and one vector store, where Cray-1 had only one port.
- **Peak**: 235 MFLOPS per CPU; 940 MFLOPS aggregate on X-MP/4.
- **Innovation**: the **Solid-State Storage Device (SSD)** — DRAM organized as a 1024-megabyte block-addressable "disk" hanging off the I/O subsystem. The first time secondary storage was fast enough to feed a vector processor.

The X-MP was the workhorse. Around 200 of them sold, vastly more than the Cray-1. The reason was the third memory port: real codes (especially solvers, FFTs, fluid dynamics) had been bandwidth-limited on the Cray-1, and the X-MP's three-port memory unblocked them.

## Cray-2 (1985): the cooled-by-immersion outlier

Seymour Cray's project, after he separated himself from the X-MP design effort.

- **Clock**: 244 MHz (4.1 ns) — three times the Cray-1.
- **Processors**: 4 "background processors" (vector CPUs) + 1 "foreground processor" (system management).
- **Memory**: 256 MW (2 GB). At delivery, by far the largest main memory in any computer ever shipped.
- **Cooling**: total immersion in **Fluorinert**, a 3M dielectric coolant. The boards literally sat in tanks of liquid that bubbled gently. (The Computer History Museum still has the bubbling-aquarium demo.)
- **Peak**: 1.95 GFLOPS aggregate.

The Cray-2 was a technology showcase but a commercial disappointment. Reasons:

- The clock was so fast that local memory references took **long enough to be visible** — 4–6 cycles, where Cray-1 references had effectively been single-cycle. Programmers had to be aware of memory layout in a new way, and a lot of legacy CFT-vectorized code didn't optimize well.
- The X-MP's three memory ports per CPU were not present on the Cray-2 (it had one port per CPU, with a much fancier crossbar to the banks). Net real-world performance was often *worse* than X-MP per CPU on bandwidth-bound code, despite the 2× clock advantage.
- The immersion cooling was operationally painful. Field engineers needed scuba gloves. (Not really. But almost.)

About 27 Cray-2s sold. It is, however, the machine that proved 2 GB of main memory was buildable, and it is one of the machines where serious large-memory CFD work became routine. Do not confuse this with the earlier Lucasfilm/Pixar work on the *Genesis* sequence in *Star Trek II* (1982): that predates both the Cray-2's 1985 shipment and RenderMan's later productization.

## Cray Y-MP (1988): the X-MP grown up

After Steve Chen left Cray in 1987 to start Supercomputer Systems Inc. (which never shipped a machine before folding), Les Davis led the Y-MP team. The Y-MP was the X-MP done correctly: same architectural concept, eight processors, full 32-bit addressing (the X-MP and Cray-1 had been stuck at 24-bit, capping memory at 16 MW), 167 MHz clock, gallium arsenide considered and rejected in favor of refined silicon ECL.

- **Processors**: up to 8.
- **Memory**: up to 256 MW (2 GB). Same as Cray-2, but X-MP-style banked.
- **Peak**: 333 MFLOPS per CPU; 2.67 GFLOPS aggregate.

The Y-MP was the **definitive** late-1980s supercomputer. Hundreds of them sold. Most national labs, most major universities, every aerospace company, oil companies, and weather services. The lineage continued as the Y-MP C90 (1991, 1 GFLOPS per CPU) and the Cray T90 (1995, 1.8 GFLOPS per CPU) — the last of the classical bespoke-ECL multiprocessor vector machines.

## The programming model: macrotasking, microtasking, autotasking

You have multiple shared-memory vector CPUs. You have one large array-heavy Fortran code. How do you exploit all the CPUs at once? Cray Research developed three layered approaches.

### Macrotasking — explicit, coarse-grained

You manually create tasks (think pthreads), each running a chunk of work, and you synchronize with events:

```fortran
      CALL TSKSTART(TID, SUBR, ARG1, ARG2)   ! launch SUBR on another CPU
      ...
      CALL TSKWAIT(TID)                       ! join
```

The granularity was meant to be coarse: independent subroutine calls, not individual loops. Used heavily in production codes that had top-level parallel structure (e.g., computing forces between independent subdomains).

### Microtasking — directive-based, finer-grained

Compiler directives marking a parallel section:

```fortran
CMIC$ DOALL SHARED(A, B, C) PRIVATE(I)
      DO 10 I = 1, N
        C(I) = A(I) + B(I)
   10 CONTINUE
```

`!MIC$` directives told the compiler to fork the loop iterations across available CPUs at runtime, then join. The pool of worker threads was managed by the runtime — fork/join was cheap (microseconds). Compare to:

```c
#pragma omp parallel for shared(a, b, c)
for (int i = 0; i < N; i++)
    c[i] = a[i] + b[i];
```

This is **the same thing**. OpenMP, when it was standardized in 1997, was substantially the union of Cray Microtasking, SGI's parallel directives, and Convex's. The fork-join model, the data-sharing clauses, the worksharing constructs — all came from this period. If you've used OpenMP, you've used Cray Microtasking at one remove.

### Autotasking — compiler does it for you

Cray's compiler could detect parallelizable loops automatically (extending the same dependency analysis CFT used for vectorization to also reason about parallelization across CPUs) and insert microtasking directives implicitly. This is the same thing modern Intel `icx -qopenmp -parallel` and IBM XL `-qsmp=auto` and NVHPC `-Mconcur` do today.

The hierarchy was: autotask first, microtask the bits the compiler missed, macrotask the high-level structure. You'd often see all three in one application.

## SAXPY on a Y-MP/8 — the full story

```fortran
CMIC$ DOALL SHARED(A, X, Y, N) PRIVATE(I) VECTOR
      DO 10 I = 1, N
        Y(I) = A * X(I) + Y(I)
   10 CONTINUE
```

What the compiler does:
1. **Outer**: split iterations across 8 CPUs (microtasking).
2. **Inner**: each CPU's chunk is strip-mined into 64-element register vectors (vectorization).
3. **Innermost**: each 64-element block is one chained vector multiply-add, fed by two memory ports per CPU.

Throughput of an idealized SAXPY on Y-MP/8: roughly 2.6 GFLOPS sustained — close to peak. This is the "compose vectorization with parallelism" pattern, and it is *exactly* what `#pragma omp parallel for simd` does today on a 96-core EPYC chip with AVX-512.

## Why this generation won

- **The programming model was incremental.** A code base that ran on a Cray-1 ran on a Y-MP unchanged, then could be sped up by adding directives. No language change required. (This was the *huge* advantage versus the Connection Machine — see Week 7.)
- **Shared memory was a familiar mental model.** Scientists already knew how to share data between subroutines. Sharing it between threads of execution was a small step.
- **The hardware was robust**. Y-MPs ran for years at facilities. The error rates of bespoke ECL were lower than people feared.

## Why this generation eventually lost

For next week and the week after — but the short version:

- **Microprocessors got fast enough**. By 1991 a single MIPS R4000 or Alpha 21064 was within striking distance of a Cray Y-MP CPU on scalar code, at 1/100 the price.
- **Aggregate scaling beat per-CPU scaling.** Twenty IBM RS/6000s or DEC Alphas, lashed together, could outperform a Cray Y-MP/8 on parallel codes for one-fifth the price. The X-MP architecture didn't scale past 8 CPUs in a shared-memory configuration; the bus and crossbar bottlenecks were brutal.
- **Cray Research's parallel response — the T3D — was distributed-memory, not shared-memory.** They saw the writing on the wall in 1992. We'll get to it in Week 8.

## Lab — OpenMP as Cray Microtasking

In `labs/04-openmp/`, you write a five-point stencil three ways: scalar serial, OpenMP-parallelized, and OpenMP+SIMD. You compare to the Cray-style three-level hierarchy and measure scaling on your laptop's cores. We provide a reference implementation that maps directly onto the Y-MP programming model so you can see the lineage.

## Discussion questions

1. The X-MP added a second and third memory port per CPU. Modern CPUs have a fixed L1 cache port count (usually 2 loads + 1 store per cycle). When does adding more ports stop being profitable?
2. The Cray-2's immersion cooling allowed a 244 MHz clock. What's the modern equivalent of "extreme cooling enables a clock advantage"? Why isn't the modern equivalent (liquid nitrogen overclocking, or production immersion at OVHcloud / Submer) being used to ship machines that run at, say, 8 GHz?
3. Microtasking, OpenMP, Apple GCD's concurrent queue, Java's parallel streams, Rust's Rayon — all are fork-join. Is fork-join *fundamental*, or is it just a happy local optimum for the kind of regular numerical code that drove Cray? What workload would make you want a different shape?

## Further reading

- Chen, S.S. (1984). "Large-scale and high-speed multiprocessor system for scientific applications: Cray X-MP series". In Hwang, [*Supercomputers: Design and Applications*](https://archive.org/details/tutorialsupercom0000unse/). Steve Chen's own description of the X-MP.
- Cray Research (1989). [*Multitasking Programmer's Reference Manual*](https://bitsavers.org/pdf/cray/CRAY_X-MP/SR-0222D_Cray_X-MP_Mulitasking_Programmers_Reference_Jul87.pdf), publication SR-0222.
- Bailey, David H. et al. (1991). "The NAS Parallel Benchmarks". *International Journal of Supercomputer Applications*. The benchmark suite that defined "fair comparison" for this generation.  See https://www.nas.nasa.gov/software/npb.html for recent documentation.
