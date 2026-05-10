# Week 8 — MIMD MPP: The Killer Micros, Connected

## Where we are in 2026

A modern supercomputer is a tightly-coupled collection of independent computers, each running a copy of an operating system, executing different parts of a parallel application, communicating over a fast network. This is the **MIMD MPP** model — Multiple Instruction Multiple Data, Massively Parallel Processor. The ideas are older, but the commercial form that won HPC took shape in the mid-1980s, was productized in the early 1990s, and decisively won the architecture war by 1996. Every Top500 entry today is some flavor of MIMD MPP with accelerators bolted on.

This week is the formative phase: 1985–1997, when the industry settled the question of how to lash thousands of microprocessors together.

## The shape of an MPP

An MIMD MPP is conceptually simple:

1. **Nodes**: each is a self-contained computer, with a CPU (microprocessor, not bespoke ECL), local memory, and a network interface. Often, a stripped-down kernel (not a full OS).
2. **Interconnect**: a fast network connecting the nodes. Topology matters: torus, hypercube, fat-tree, dragonfly. Latency and bandwidth dominate the system's character.
3. **Programming model**: each node runs a separate process. Processes communicate by *sending messages* over the network or, in some designs, by *directly accessing remote memory* (one-sided communication / SHMEM).

The hard part is the interconnect. The hard part has *always* been the interconnect.

## Intel iPSC family (1985–1990)

Intel's first MPP, the **iPSC/1** (1985), was 32 to 128 Intel 80286 nodes connected in a hypercube — an explicit homage to the Connection Machine, but with full general-purpose microprocessors instead of bit-serial SIMD elements. The iPSC/2 (1988) used 386 + 387 nodes; the iPSC/860 (1990) used the i860 vector microprocessor, the first time a "supercomputer-class" microprocessor was used as a node. *Sources: Intel iPSC product literature (1985–1990); Pierce (1988) for the NX/2 operating environment that shipped on the iPSC/2 and Paragon.*

The iPSC family was a cautious commercial success. It established that you could *sell* MPPs to scientific customers if the per-CPU performance was good and the interconnect was fast enough. It also shipped the first credible programming environment for MPPs: **NX**, Intel's message-passing library, the direct ancestor of MPI.

NX let a programmer write:

```c
csend(message_type, buffer, length, dest_node, dest_pid);
crecv(message_type, buffer, length);
```

That's the entire conceptual surface. Two operations: send a message, receive a message. Build everything else from that. (PVM, the Parallel Virtual Machine project at Oak Ridge from 1989, was a portable cross-vendor version of the same idea.)

## Intel Paragon (1992)

The iPSC's successor was the **Intel Paragon XP/S**:

- **Up to 4,096 i860 XP nodes**, each running a per-node microkernel called **OSF/1**.
- **2D mesh interconnect**, 200 MB/s per link.
- **Peak**: 300+ GFLOPS aggregate.
- **OS**: each node ran a thin partition of OSF/1. Service nodes ran a full UNIX. Compute nodes ran a stripped microkernel. This *node specialization* is now standard on every supercomputer; the Paragon invented it.

*Sources: Mattson (1995) for the Paragon programming and OS environment; Top500 June 1994 list for the brief #1 placement; Intel SSD Paragon XP/S product specification (1992) for link bandwidth and topology.*

Sandia's Paragon hit Top500 #1 briefly in 1994. It was the proof of concept for ASCI Red, which we'll see shortly.

## Cray T3D (1993) and T3E (1995): Cray's MPP turn

Cray Research, watching microprocessors close the gap, did not stand still. They acquired networking expertise, partnered with DEC for Alpha microprocessors, and built an MPP around them.

### T3D (1993)

- **DEC Alpha 21064** at 150 MHz, 32 to 2,048 nodes.
- **3D torus interconnect**, 300 MB/s per link, sub-microsecond latency.
- **Globally addressable memory**: the T3D was the first MPP to expose all the memory in the machine as one shared address space, with explicit fast load/store instructions for remote memory (the **SHMEM** library).
- **No OS on compute nodes**; just a user program and a thin runtime. Compute nodes were mute and stripped.

*Sources: Cray Research T3D system architecture overview (1993); the SHMEM model is documented in the Cray T3E Programming Environment manual (SR-2017), which describes the inherited T3D mechanism.*

The 3D torus was the design's signature. Why a torus? Because for the kinds of physics simulations that filled DOE labs (hydrodynamics, particle-in-cell, lattice QCD), the data-access pattern was a 3D grid with nearest-neighbor communication. Mapping the application's grid onto a physical 3D torus minimized communication distance — most messages traveled one hop.

### T3E (1995): the most successful pure MPP ever sold

- **DEC Alpha 21164** at 300–600 MHz, scaling to 2,048 CPUs.
- **Same 3D torus**, faster and bigger.
- **Peak**: ~1.2 TFLOPS at the high end.
- **Sales**: dozens of major installations. ECMWF, US labs, Pittsburgh Supercomputing Center, NERSC, the UK Met Office.

*Sources: Cray Research T3E system architecture documentation (SR-2017); Scott & Thorson (1996) for the adaptive routing in the T3E 3D torus; Top500 lists 1996–2003 for installations and peak figures.*

The T3E was the apex of the MPP form factor. It was also Cray Research's last truly successful product line before the SGI acquisition in 1996. The T3E ran for many years; the Pittsburgh "BigBen" T3E ran until 2003, ECMWF's until 2002. Codes that ran well on T3E ran well on later clusters with minimal porting — the SHMEM model survived (in fact, OpenSHMEM is still standardized today).

## IBM SP1 (1993) and SP2 (1994)

IBM's MPP take was different and ultimately more commercially successful than Cray's:

- **Nodes were full RS/6000 workstations**, each running full AIX, each independently capable.
- **High-Performance Switch** (HPS): a multi-stage interconnect with substantial bandwidth and OK latency.
- **Programming**: native MPL (IBM's message passing) and MPI; PVM also widely used.
- **Killer application**: ASCI Blue Pacific (LLNL, 1998), Deep Blue (the chess machine that beat Kasparov, 1997 — a 30-node IBM RS/6000 SP system with custom chess accelerator chips).

*Sources: Agerwala et al. (1995), "SP2 System Architecture," IBM Systems Journal 34(2):152–184, for switch and node design; Hsu et al. (1990) and IBM RS/6000 SP product literature for the per-node specifications; IBM Deep Blue project documentation (1997) for the chess-accelerator system size.*

IBM's choice to make every node a *full standalone system* was strategically clever. Customers could buy a small SP cluster, grow it incrementally, and not have to retrain people on a stripped-down compute node OS. This is the architectural pattern that won — modern Frontier nodes are full Linux systems, not stripped microkernels.

## ASCI Red (1997): the first sustained TFLOPS

The **Accelerated Strategic Computing Initiative** (ASCI) was the DOE's response to the 1992 nuclear test moratorium: instead of physical tests, the US would simulate weapon physics. This required several orders of magnitude more compute than was available in 1995.

**ASCI Red** (Sandia, 1997): the first machine to sustain 1 TFLOPS on LINPACK.

- **9,632 Pentium Pro nodes** (later upgraded to Pentium II Xeon), 200 MHz.
- **38×32×2 mesh interconnect**, partitioned into compute, service, and I/O nodes.
- **1.8 TFLOPS peak**, 1.06 TFLOPS sustained on HPL.
- **Cost**: ~$55M. Vastly cheaper per FLOP than any vector machine.
- Held Top500 #1 from 1997 through mid-2000.

*Sources: Mattson & Henderson, "ASCI Red: experiences and lessons learned with a massively parallel teraFLOP supercomputer" (Intel/Sandia, SC97); Foster et al. (2005) for the program-level retrospective; Top500 lists June 1997 through November 2000 for the #1 reign and Rmax = 1.06 TFLOPS sustained.*

ASCI Red was the moment the American HPC establishment publicly committed to the MIMD MPP path. Every subsequent ASCI/ASC machine through ~2015 was the same template: enormous numbers of commodity CPUs, custom interconnect, partitioned OS, message-passing software stack.

## The two programming models: SHMEM vs. MPI

There were two competing message-passing models in the early 1990s:

**Two-sided (MPI, NX, PVM)**: matched send/receive. Sender calls `send(msg, dest)`, receiver calls `recv(msg, src)`. Both must participate. Conceptually like a function call across the network.

**One-sided (SHMEM, on T3D/T3E)**: `shmem_put(remote_addr, local_addr, len, pe)` — write data into another process's memory directly, no participation required from the target. Conceptually like a remote pointer dereference.

One-sided was *faster* — no synchronization, just RDMA-style memory operations. Two-sided was *more portable* — didn't require globally addressable memory hardware. Two-sided won because portability won, but one-sided survived (modern MPI has `MPI_Put` and `MPI_Get`, and OpenSHMEM is still a standard, used heavily by graph workloads).

If you look at the modern stack: **CXL.mem**, **NVLink**, **NVSwitch**, and the GPU memory abstractions in CUDA Unified Memory — these are all bringing back one-sided memory operations on a per-node-cluster scale. The T3E got there 30 years early.

## Why MPP won

- **Per-FLOP cost**: a Pentium Pro at $1k versus a Cray Y-MP CPU at $1M. Even after the interconnect tax, MPPs were 10–100× cheaper per FLOP.
- **Scalability**: doubling the FLOPS meant adding nodes, not redesigning the CPU. The X-MP/Y-MP topped out at 16 CPUs; T3E scaled to 2,048; ASCI Red to 9,632.
- **Software portability**: source code that ran on a T3E ran on an SP2 ran on a Beowulf cluster, with at most a recompile. The MPI standard (Week 9) made this concrete.

## What MPP cost the programmer

- **Distributed memory**. You can no longer just declare a giant array and use it; you have to think about which process owns which slice, and how to communicate between them.
- **Manual data partitioning**. Domain decomposition, halo exchange, load balancing — all became central concerns.
- **Latency awareness**. A network round-trip is hundreds of CPU cycles. An algorithm that worked on shared memory might be terrible if mapped naïvely onto distributed memory.
- **Failure modes**. With thousands of nodes, mean time between failures becomes hours, not weeks. You now need checkpointing.

These costs are real and have not gone away. They are the costs every modern HPC programmer pays.

## Lab — Toy MPP simulator

In `labs/08-mpp-toy/`, you build a Python simulator of a 16-node 4×4 mesh MPP. Each node has a queue for incoming messages and a small program. You implement a halo-exchange stencil computation and measure how the choice of mesh topology affects the total time. Then you re-run with a hypercube topology (same node count, different wiring) and observe the difference. The point: interconnect topology has visible effects on simple algorithms.

## Discussion questions

1. The T3D exposed a globally addressable memory model. Modern accelerator stacks are re-introducing this: NVIDIA's "Grace Hopper" Superchip combines a CPU and GPU sharing one address space; CXL.mem extends a server's memory across PCIe to neighbors. Why is the global-address-space model coming back now? What enabled it (or made it tolerable) that wasn't true in 1995?
2. The Paragon and ASCI Red ran a stripped microkernel on compute nodes. Modern Frontier and Aurora run full Linux. Why did the trend reverse?
3. PVM vs. MPI — both were portable message-passing standards in the early 1990s. MPI won decisively. Read the early MPI Forum minutes (online) and identify the two or three design decisions that gave MPI its advantage. How would you apply those lessons today, e.g., to standardizing AI accelerator APIs?

## Further reading

- Pierce, P. (1988). "The NX/2 Operating System". *Proc. Hypercube Concurrent Computers and Applications Conference*. NX was MPI's most direct precursor.
- Cray Research (1995). *Cray T3E Programming Environment*, publication SR-2017. Defines SHMEM and the T3E one-sided model.
- Mattson, T.G. (1995). *Programming with the Intel Paragon*. Practical view of an MPP from the user's seat.
- Geist, A. et al. (1994). *PVM: Parallel Virtual Machine*. MIT Press. Online.
- Reed, D. (2003). "ASCI Red: A history". *HPCwire*.
- Top500 lists from June 1993 through June 2000 — read them in sequence; the architectural shift is visible year over year.
