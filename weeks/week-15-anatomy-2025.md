# Week 15 — Anatomy of a 2025 Supercomputer

## Where we are in 2026

A modern supercomputer is not a single machine. It is a tightly-coupled datacenter, optimized for one job at a time, where the *system* — not any individual node — is the unit of design. Understanding it requires understanding power, cooling, interconnect, storage, software, and operations as a coherent whole, because it is in the integration that the engineering happens.

This week is the operational picture. What goes into Frontier, in 2025, beyond the FLOPS? And how does the answer differ from what Cray sold in 1976?

## Compute: the node is itself a small supercomputer

Frontier-class compute node, drawn from the public spec sheet:

- **CPU**: 1× AMD EPYC "Trento" 7A53 — 64 cores at 2.0 GHz base, AVX2 (256-bit) vector unit per core. ~2 TFLOPS peak FP64 from the CPU alone (which would have been #1 on the Top500 in 1995).
- **GPUs**: 4× AMD Instinct MI250X — 2 GCDs each = 8 GCDs per node. ~84 TFLOPS peak FP64.
- **Memory**: 512 GB DDR4 attached to CPU, 512 GB HBM2e attached to GPUs (64 GB per GPU).
- **Local NVMe**: 1.92 TB.
- **NIC**: 4× HPE Slingshot Cassini network interfaces, 200 Gb/s each.
- **Power per node**: ~5 kW.

A single Frontier compute node has *more compute, more memory, and more network bandwidth than every supercomputer on Earth had combined in 1985*. Multiply by 9,408 nodes to get the system.

The implication: a working engineer who wants to think about a modern supercomputer should think about a single node first (it's a familiar object — a multi-socket fat server with accelerators), then think about how 10,000 of them are wired together.

## Interconnect: the system's distinctive component

The interconnect is what separates a supercomputer from a colocation rack of servers. The relevant specifications:

- **Bandwidth per port**: 200 Gb/s (Slingshot-11), 400 Gb/s (NDR InfiniBand), 800 Gb/s (XDR, shipping now, in some 2025 systems). Up from 1 Gb/s on Quadrics (1998).
- **Latency**: ~1 µs end-to-end for small MPI messages on modern fabrics; was 10 µs on Myrinet (1995).
- **Topology**: **dragonfly** is dominant for general-purpose HPC (Slingshot, Aries before it), **fat-tree** common for AI clusters, **torus** still favored for some physics workloads. Dragonfly is hierarchical: groups of nodes form "groups", groups have all-to-all links to other groups, the system has a small diameter.
- **Adaptive routing**: packets dynamically choose paths based on observed congestion. The simple "static shortest path" routing of older fabrics is gone.
- **Lossless transport**: link-level credits, not TCP-style retransmission. Buffer overflow is *not allowed*; flow control prevents it.
- **RDMA**: every modern HPC NIC supports **remote direct memory access** — the NIC reads/writes memory on the remote node without involving the remote CPU. This is what makes one-sided MPI and SHMEM operations fast.
- **Hardware collectives**: dedicated hardware in the switches accelerates `MPI_Allreduce` and the like. Mellanox SHARP, HPE Slingshot's collective offload — the trees of summing operations are done in the network rather than at the endpoints.
- **In-network processing**: BlueField DPUs and Slingshot's NIC processors offload protocol handling, security, and even some application-level operations.

If you want to identify the most "supercomputer-distinctive" hardware in a modern system, point at the interconnect. The CPUs and GPUs are off-the-shelf. The interconnect is bespoke.

## Storage: the parallel filesystem

Compute nodes don't have local disks for application data. They mount a **parallel filesystem** that aggregates dozens to hundreds of storage servers into one logical filesystem. The standard options:

- **Lustre**: open-source. Most widely deployed in HPC. Frontier, Aurora, Fugaku all run Lustre.
- **IBM Spectrum Scale (formerly GPFS)**: proprietary, well-regarded. Sequoia/Sierra/Summit at LLNL/ORNL.
- **DAOS** (Distributed Asynchronous Object Storage): Intel-led, object-based, designed for NVMe. Aurora's primary storage.
- **BeeGFS**: open-source, popular for mid-sized clusters.

Throughput on a production parallel filesystem is now in the **terabytes per second** range. Frontier's "Orion" Lustre filesystem provides about 5 TB/s aggregate read bandwidth, 4 TB/s write, on 11.5 PB of NVMe and 679 PB of HDD.

The architectural shift from spinning rust to NVMe (around 2018 for HPC) was as significant as the move from tape to disk in the 1980s. Modern systems have a tier-rich storage hierarchy:

1. **GPU HBM**: TB/s bandwidth, GB capacity, μs latency. Per-GPU.
2. **CPU DDR**: hundreds of GB/s, ~100 GB capacity, ~100 ns latency. Per-node.
3. **Local NVMe (node-local burst buffer)**: ~10 GB/s, ~TB capacity, ~10 μs latency. Per-node.
4. **Cluster-shared NVMe (e.g., DAOS)**: ~TB/s aggregate, ~PB capacity, ~ms latency.
5. **Cluster-shared HDD (Lustre, GPFS)**: ~hundreds of GB/s aggregate, ~hundreds of PB, ~10 ms latency.
6. **Tape archive**: GB/s, EB capacity, minute-to-hour latency.

Programming applications that span these tiers explicitly is a research area. **Burst buffer** APIs let an application stage data through fast NVMe before doing slow operations on Lustre.

## Software: the pyramid

The software stack on a 2025 supercomputer, bottom up:

- **OS**: Linux (HPE Cray OS = SUSE Linux Enterprise Server with custom drivers, on Frontier; RHEL on others). Stripped-down compute-node configuration plus full user-environment login nodes.
- **Drivers and libraries**: vendor-specific accelerator stacks (CUDA, ROCm, oneAPI), high-performance MPI (Cray MPT, Intel MPI, OpenMPI, MPICH), scheduler (Slurm in 95%+ of cases).
- **Module system**: `module load openmpi/5.0` etc., for managing multiple compiler/library versions side by side. **Lmod** is the dominant implementation.
- **Package management for HPC**: **Spack** (LLNL) for building scientific software stacks from source with optional ABI-compatible binaries. **EasyBuild** in some European sites.
- **Containers**: **Apptainer** (formerly Singularity) is the HPC-native container runtime — built specifically for security models that don't allow root, and for performance integration with MPI and InfiniBand. Docker doesn't fly in HPC.
- **Job scheduling**: **Slurm** writes the job queue, allocates nodes, executes job scripts. PBS/Torque on a few sites; LSF on legacy IBM machines.
- **Monitoring**: a stack of Prometheus, Grafana, custom Cray/HPE telemetry, NVIDIA DCGM, AMD SMI. Power, temperature, network counters, GPU utilization — every metric, every node, every second.
- **User workflow tools**: **Snakemake**, **Nextflow**, **Parsl** for orchestrating long pipelines across many jobs.
- **Data movement**: **Globus** for inter-site transfers (terabytes between sites is a normal weekly operation), **mpi-IO** within the system.

## Power and cooling

A 30 MW supercomputer dissipates 30 megawatts of heat. To put that in scale: 30 MW would heat ~10,000 single-family homes. It must be removed continuously.

The dominant approach is **direct liquid cooling** with warm water:

1. Coolant water enters the building at ~30°C (warm — the cooling tower can produce this from a 10°C wet bulb without chillers).
2. It flows through cold plates clamped to CPUs and GPUs, picking up heat to ~40°C.
3. The hot return water goes to evaporative cooling towers or, increasingly, to **building heat-recovery** systems that warm offices or hot-water systems.

The thermodynamic advantage over chilled-air cooling is enormous: 30°C inlet means the cooling-tower duty is small (no compressors), compared to traditional 12°C chilled water that requires substantial chiller plants.

Two-phase cooling (the working fluid evaporates in the cold plate, condenses in a heat exchanger) is in use at some sites and is the next step. Full **immersion cooling** (servers submerged in dielectric fluid, like the Cray-2 in 1985 at much smaller scale) is shipping in some commercial datacenters and a few HPC sites; LLNL announced plans for immersion cooling in next-generation systems.

The site selection for a modern HPC center is dominated by:

- **Power availability and price.** ORNL benefits from TVA hydroelectric. RIKEN gets Kansai grid power. Argonne gets ComEd nuclear baseload.
- **Cooling water availability.** Either lake/river access or a large reclaimed-water supply.
- **Land for substations and cooling towers.** A modern HPC site footprint is mostly utility plant.

## Operations

A few statistics that are not on any architecture diagram but determine how the systems actually work:

- **Mean time between hardware failure (MTBF) at the node level**: typically a few months. With 10,000 nodes, that's *several failures per day across the system*. Applications must checkpoint, and the scheduler must reschedule failed jobs.
- **Effective utilization**: well-managed sites run at 70–90% utilization, measured as "fraction of node-hours used by production jobs." Below 70% suggests scheduling or queuing problems; above 90% is unusual.
- **Job size distribution**: highly skewed. Most jobs are small (single-node-hour). A few jobs each year use the entire machine ("hero runs" — climate simulations, weapons calculations, ML pretraining). The scheduler has to fit them all in.
- **Allocations**: in DOE labs, time on the machine is granted by competitive proposal. At LLNL, ORNL, Argonne, the **INCITE** and **ALCC** programs grant time on Frontier, Aurora, Polaris, etc., with proposals reviewed by panel. Most users are *not* the people who paid for the machine.

## How it differs from what Cray sold in 1976

Recall the Cray-1:

- 1 CPU at 80 MHz, 8 MB memory, 5 tons, 115 kW, 160 MFLOPS, $8.8M.
- A *single user, single program* machine. The OS — COS, then later UNICOS — ran one job at a time on the central processor; everything else was the I/O subsystem.
- Bespoke ECL throughout. Built by Cray Research employees in Chippewa Falls; every chip was custom.
- Programmed in CFT Fortran or CAL. The compiler emitted vector instructions; the programmer reasoned about a single fast pipeline.

Frontier:

- 9,408 nodes, each with 64-core CPU + 4 GPUs, 5 PB total memory, 14,000 ft² floor, 21 MW, 1.2 EFLOPS, ~$600M.
- A *thousand-user, hundreds-of-jobs-at-a-time* machine, with dynamic job scheduling. There is no "one program" per machine; there is a job queue.
- Commodity throughout: AMD CPUs (volume product), AMD GPUs (HPC variant of a volume product), HPE Cray interconnect (the only truly bespoke bit), Linux (free software), Slurm (free software), Lustre (free software).
- Programmed in MPI for the cross-node parallelism, OpenMP/HIP/CUDA for the on-node parallelism, with codes that have been continuously evolved for thirty years across multiple machine generations.

The architectural change from "single fast machine" to "fleet of coordinated machines" is total. The technology is unrecognizable.

But — and this is the point of the course — the *intellectual lineage* is direct. Frontier's GPUs are vector machines, descendants of the Cray-1 by way of the Connection Machine and CUDA. Frontier's MPI runtime descends from CFT and ASCI's NX. Frontier's Slingshot interconnect descends from the Cray T3E torus. Frontier's parallel Lustre filesystem descends from CDC's I/O subsystems. Frontier's compiler stack descends from CFT and Kuck's Parafrase.

The architecture changed. The ideas walked through.

## Lab — A virtual datacenter

In `labs/15-virtual-dc/`, we set up a small "datacenter" with:
- 4 Docker-container "compute nodes" running Slurm and OpenMPI.
- 1 "head node" with the Slurm controller and a shared NFS volume.
- A simple "monitoring" view via Grafana (optional).

You submit a multi-node MPI job to this miniature, watch it scheduled, watch it run, watch the (artificial) telemetry roll in. You also kill a "node" mid-job and observe the failure mode. The point: see in miniature what the operations team at ORNL is doing in production, and feel the difference between writing code and running a production HPC service.

## Discussion questions

1. The "interconnect is the most distinctive part of a modern supercomputer" claim. Is it still true if you compare to a hyperscale AI training cluster (e.g., NVIDIA DGX SuperPOD with NVLink + InfiniBand)? Are AI clusters supercomputers, or something else?
2. Modern HPC sites depend on warm-water cooling and dense liquid plumbing. What's the largest *consumer-grade* analog? At what scale would your home computer benefit from liquid cooling? Why don't most consumer machines have it despite the apparent cooling advantage?
3. The Cray-1 had one program at a time. Frontier has thousands. Did the change in time-sharing model also change what a "supercomputer" is for, in terms of who uses it and what it accomplishes?

## Further reading

- ORNL (2022). *Frontier System Architecture*. Public technical reports on olcf.ornl.gov/frontier.
- HPE (2021). *HPE Slingshot Architecture White Paper*. Specification for the dragonfly interconnect.
- Garcia, K. et al. (2022). "El Capitan: An advanced architecture exascale system at LLNL". *Proc. SC22*.
- Schwan, P. (2003). "Lustre: Building a file system for 1000-node clusters". *Linux Symposium*. The Lustre design paper, still relevant.
- Yoo, A.B. et al. (2003). "SLURM: Simple Linux Utility for Resource Management". *JSSPP '03*.
- For modern operations and lifecycle: ECP final report (Argonne, 2023) and the OLCF/ALCF/NERSC user documentation (free online).
