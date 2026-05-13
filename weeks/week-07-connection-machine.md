# Week 7 — The Connection Machine: SIMD Massively Parallel

## Where we are in 2026

Every modern GPU is, internally, a SIMD massively-parallel machine. A single CUDA "warp" is 32 threads executing the same instruction in lockstep on different data. A NVIDIA H100 has 16,896 CUDA cores running at warp granularity. The architectural philosophy — *thousands of simple processors executing one program on different data* — was prototyped fifteen years before the first GPGPU paper, by a startup that built a beautifully strange machine and then went bankrupt: **Thinking Machines Corporation**, with the **Connection Machine** series.

This week we look at the most architecturally interesting commercial failure in the history of supercomputing.

## The MIT origin story

Daniel Hillis was a graduate student at the MIT Artificial Intelligence Lab in the early 1980s, working with Marvin Minsky. His PhD thesis (1985) was titled *The Connection Machine* — an argument that AI workloads (knowledge representation, semantic networks, vision) needed a fundamentally different architecture: one where **memory and processing were colocated**, with a processor at every word of memory, and a fast interconnect that let them all communicate.

The thesis argued the right number of processors was around 65,536, the right per-processor compute was *trivially small* (a 1-bit ALU, a few words of RAM), and the right interconnect was a **hypercube** of dimension 16 (so any processor could reach any other in 16 hops).

Thinking Machines Corporation was founded in 1983 to build it. The first machine, the **CM-1**, shipped in 1985.

## CM-1 (1985)

- **65,536 1-bit processors**, each with 4 kilobits of local RAM (yes, 4 kilo*bits*), arranged on a 12-dimensional **hypercube** interconnect.
- **No floating point**. Multi-bit integer or floating-point arithmetic was synthesized bit-serially across cycles. A 32-bit add took ~32 cycles.
- **Clock**: 4 MHz.
- **Cost**: about $5M.
- **Cabinet**: an iconic 5-foot black cube, blinking with red LEDs (one per processor), now a museum piece. The cube design was deliberate — for the trade-show floor and for the reaction shot in the *Jurassic Park* film (a CM-5 actually, but the visual lineage was CM-1).

Hillis's bet was that:

1. AI-style workloads (graph traversal, neural networks, image processing) had abundant data parallelism — millions of independent operations per problem.
2. A processor per data element was the natural fit.
3. Bit-serial was OK because the processors were so cheap you could afford to waste cycles per word and still come out ahead in throughput per dollar.

The bit-serial bet was technically correct for some workloads (image processing, content-addressable search) and totally wrong for others (anything floating-point heavy). When the CM-1 met its first scientific-computing customers, the answer was "we love the architecture, where's the FPU".

## CM-2 (1987): floating point bolts on

- Same 65,536 1-bit processors (organized in groups of 32 on each chip), **but**:
- One **Weitek 32-bit floating-point coprocessor** added per group of 32 processors. So 2,048 FPUs across the machine.
- 64 Kbits of RAM per 1-bit processor in common CM-2 configurations, with larger aggregate memory options available. A fully configured 65,536-processor CM-2 could reach hundreds of megabytes total, but that is kilobytes per processor, not hundreds of kilobytes.
- **Peak**: ~2.5 GFLOPS — comparable to a Cray Y-MP/8, at substantially lower cost.

The CM-2 was the machine that made Thinking Machines briefly important. Sandia, Los Alamos, several oil companies, and a clutch of universities bought them. Algorithms developed for them — particle simulations, certain kinds of fluid dynamics, neural network training (the precursors to modern deep learning, in fact) — ran beautifully.

It is genuinely worth pausing on this: in 1988, a Connection Machine running a backpropagation neural network was the fastest neural-net training rig in the world. The architectural fit between SIMD massive parallelism and neural network training was already obvious. It just took until ~2012 (Krizhevsky, AlexNet, on a pair of NVIDIA GPUs) for the workload to become big enough to drive a market.

## What the code looked like

Three languages mattered on the Connection Machine. All of them have modern counterparts you'd recognize.

### `*Lisp` — data-parallel Common Lisp

Lisp with parallel-array primitives:

```lisp
(*let ((x (!! 0)))                     ; x is a 64K-element parallel array
  (*set x (+!! a b))                   ; element-wise add: x = a + b across all 64K
  (*let ((s (sum!! x)))                ; reduction across all 64K processors
    s))
```

The `!!` suffix marks an operation as "happen at every processor in parallel". `sum!!` is a global reduction, implemented in $O(\log N)$ using the hypercube — every processor exchanges with its neighbors, halving the unique-summed count each step.

### `C*` — data-parallel C

```c
shape [65536]ProcessorGrid;
double:ProcessorGrid x, y, z;     /* parallel arrays */
[ProcessorGrid] z = x + y;        /* element-wise add */
double s = (+= x);                /* reduction sum */
```

`shape` types declared the parallel domain. Variables declared `T:Shape` were implicitly parallel — one element per processor in the shape. Operators auto-broadcast and auto-reduced.

### CM Fortran — what eventually became Fortran 90

```fortran
      REAL, ARRAY(65536) :: A, B, C
      C = A + B                  ! whole-array assignment, runs in parallel
      S = SUM(A)                 ! reduction
      WHERE (A > 0) C = A * 2    ! masked, all in parallel
```

This is recognizably the same idiom as **Fortran 90 array syntax** before Fortran 90 was formally standardized. Whole-array operations, masked assignment, broadcast, and reductions shipped on the CM-2 in 1988 while the Fortran 8x/90 standardization process was already underway. The Connection Machine did not single-handedly invent Fortran 90's array model, but it productized the data-parallel style early and helped prove that the idiom was usable at machine scale.

This is one of the most underappreciated design influences in the history of programming languages.

## The lesson the Connection Machine taught — and learned

The lesson it *taught*: you can write data-parallel code, in a high-level language, and have it run efficiently on thousands of processors, *if* the language is built for parallelism from the start. You don't need to bolt on `pthread_create` or `MPI_Send`. You just need parallel array operations as a first-class language feature.

This is the lesson NumPy users use every day. It's the lesson Halide and Triton are built around. It's *exactly* what CUDA's grid-of-threads abstraction does at a slightly lower level. Hillis was right about the abstraction.

The lesson the Connection Machine *learned*, painfully: **rigid SIMD doesn't scale to the workloads people actually have.** The CM-2 was strict SIMD: every processor executed the same instruction every cycle. If your algorithm had branches that took different paths on different data, half your processors had to NOP while the other half ran. Real applications had a lot of branches.

The CM-5 (1991) was Thinking Machines' attempt to fix this. They abandoned SIMD entirely and went MIMD — every node was an independent SPARC-based workstation, with a 4-element vector unit per node, lashed together with a fat-tree interconnect. It worked technically, but it was no longer architecturally novel: a CM-5 was a fancy MIMD MPP, and IBM and Intel and Cray were going to build cheaper ones.

Thinking Machines filed for Chapter 11 in **August 1994**.

## What survived

- **Hypercube interconnect** influenced the Intel iPSC and IBM SP2 networks.
- **Data-parallel array syntax** helped shape Fortran 90 practice, NumPy, MATLAB, and indirectly NumPy → JAX → PyTorch's tensor operations.
- **The PRAM-ish programming model** influenced CUDA's grid-and-block abstraction (one thread per data element, hardware schedules them in warps of 32 — a *softer* SIMD that handles branch divergence by masking inactive lanes).
- **The Star Lisp / C\* community** dispersed and ended up at Sun, Sequent, and Intel, where their data-parallel-language thinking influenced the OpenMP design and the Intel Threading Building Blocks team.

If you have ever written `numpy.where(a > 0, b, c)` instead of a loop with an `if` statement — you are writing CM Fortran, with sixty-four-million-times-larger data sizes and sixty-four-million-times-faster hardware. The continuity is direct.

## Coda: HPF, and what didn't survive

If the Connection Machine taught the lesson that data-parallel array operations belonged in the language, the obvious next move was: *standardize that, take it cross-vendor, and make it work on distributed-memory machines too*. The result was **High Performance Fortran** (HPF), drafted by an industry-academic forum from 1991 to 1993 and shipped by Cray, IBM, Intel, HP, DEC, NEC, Fujitsu, Lahey, and PGI in commercial compilers by 1995.

HPF took Fortran 90's array syntax — the syntax CM Fortran had just established — and added a small set of directives that told the compiler *how data was distributed across processors*. SAXPY in HPF:

```fortran
SUBROUTINE SAXPY_HPF(N, A, X, Y)
  REAL :: A, X(N), Y(N)
!HPF$ PROCESSORS PROCS(NUMBER_OF_PROCESSORS())
!HPF$ DISTRIBUTE X(BLOCK) ONTO PROCS
!HPF$ ALIGN Y(:) WITH X(:)
  Y = A * X + Y
END SUBROUTINE
```

The compiler was supposed to: split `X` into block-distributed chunks across processors, co-locate `Y` with `X`, generate the local computation, and generate whatever communication was needed for non-element-local operations. In principle, the programmer never wrote a send or receive.

It failed. By 1998 every major vendor had quietly stopped investing in HPF. The reasons are worth understanding because they are the same reasons high-level parallel languages keep failing:

1. **Compiler complexity exceeded the state of the art.** Inferring optimal communication patterns from declarative data-layout hints is, in general, undecidable. The compilers shipped, but their generated code was unpredictable and often slow.
2. **Performance was non-portable in a *new* way.** With MPI, the programmer wrote communication explicitly — so it was at least *legible*. With HPF, two compilers from two vendors could turn the same source into wildly different communication schedules. HPC programmers couldn't tune what they couldn't see.
3. **The standard had real gaps.** Irregular workloads (sparse matrices, unstructured grids, adaptive meshes) were awkward to express. The very kernels that needed parallelism most were the ones HPF couldn't handle cleanly.
4. **MPI was already winning the same problem.** By 1994 the national labs had MPI codes that ran; they were not going to rewrite them for a compiler with bugs.

The HPF ambition — *declarative data layout, the compiler does the work* — keeps coming back. **Chapel** (Cray, 2009 onward), **X10** (IBM), **Fortress** (Sun, canceled), **Coarray Fortran** (folded into Fortran 2008), **UPC**, **Julia's distributed arrays**, and arguably **JAX/XLA**'s sharding annotations for ML are all spiritual descendants. None has displaced MPI for production HPC. The pattern is durable: declarative parallelism is elegant; predictable performance wins customers.

## Lab — `numpy` as a Connection Machine emulator

In `labs/07-data-parallel/`, you implement Conway's Game of Life and a simple cellular automaton three ways:

1. Imperative, Python loops.
2. NumPy whole-array (the `C*` / CM Fortran way).
3. CuPy on a GPU (or NumPy with `numba.cuda` if no GPU; or skip if you have neither).

Then you visualize the result. The point: the *programming idiom* the Connection Machine taught us is now the lingua franca of scientific Python. You write `next_grid = update_rule(grid)` and the runtime handles the parallelism. That's what Hillis meant.

## Discussion questions

1. The CM-2 had 65,536 processors. A modern NVIDIA H100 has 16,896 CUDA cores grouped into warps of 32. Are these architecturally the same idea, or is the warp-based SIMT model fundamentally different from CM-2's bit-serial SIMD?
2. CM Fortran shipped data-parallel array syntax in 1988. Fortran 90 standardized it in 1991. NumPy adopted it in 1995. Why did it take *another twenty years* (until ~2015) for this idiom to become the default in mainstream high-performance Python?
3. The Connection Machine failed commercially in 1994. The architectural ideas it championed (data-parallel languages, processor-per-element) won completely 20 years later. Find another instance where the architecture won but the company that pioneered it didn't survive long enough to benefit. What does that pattern say about how to bet on architectures?

## Further reading

- Hillis, W.D. (1985). [*The Connection Machine*](https://archive.org/details/connectionmachin00hill). MIT Press. Out of print but downloadable from Hillis's site. Required reading.
- Hillis, W.D. & Steele, G.L. (1986). ["Data parallel algorithms"](https://doi.org/10.1145/7902.7903). *CACM*. The argument for the model.
- Steele, G.L. & Hillis, W.D. (1986). ["Connection Machine Lisp: Fine-grained parallel symbolic processing"](https://doi.org/10.1145/319838.319870). *LFP'86*. Steele was Thinking Machines' compiler luminary.
- [*Programming the Connection Machine in C\* and CM-Fortran*](https://archive.org/details/thnkingmachinesc01unse). Thinking Machines documentation.
- Murray, *The Supermen*, chapter 16 — covers Cray's reaction to the Connection Machine.
