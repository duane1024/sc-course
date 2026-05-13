# Week 9 — MPI: The Standard That Stuck

## Where we are in 2026

The Message Passing Interface, MPI, has been the dominant programming model for distributed-memory parallel computing for more than thirty years. *Every* machine in the Top500 supports it. Every major scientific code uses it directly or indirectly. The current MPI standard is MPI-5.0, approved by the MPI Forum in 2025; it is hundreds of pages, with thousands of functions, but the core conceptual surface is the same six calls it had in 1994. This is the rare standardization success in HPC: a portable, vendor-neutral API that vendors actually implemented and users actually adopted.

This week is about how MPI works, why it won, and how to write the code your grandparents would recognize.

## The MPI Forum and the standardization process

In April 1992, frustration with the proliferation of incompatible message-passing libraries (Intel NX, PVM, IBM MPL, Vendor X's library, Vendor Y's library) drove a workshop at Williamsburg, Virginia. Out of it came the **MPI Forum**: a working group of vendors (Intel, IBM, Cray, TMC), labs (LANL, ORNL, Argonne), academics (Mississippi State, Edinburgh, Rice). They met for two years.

**MPI-1** was published in May 1994. **MPICH** (Argonne and Mississippi State) and **LAM/MPI** (Ohio Supercomputer Center) were free reference implementations. Vendors built their own optimized versions. The standard worked because:

1. The Forum required two independent implementations before any feature was standardized — this killed unrealistic specifications.
2. The Forum included both vendors and large customers — so neither side could write a standard the other refused to implement or use.
3. The standard was substantially based on already-deployed designs (NX, PVM, Zipcode), not invented from scratch — it codified existing practice.

It's a good model. People should study it more than they do.

## The conceptual core

MPI is built on five concepts:

1. **Process group**: a set of processes participating in computation. Static, set at job launch by `mpiexec`.
2. **Rank**: each process has a unique integer ID, 0 to N-1.
3. **Communicator**: a handle that wraps a process group and a context. `MPI_COMM_WORLD` includes all processes; you can create sub-communicators for collective operations on subsets.
4. **Message**: a buffer of typed data, plus a tag (integer used for matching) and source/dest ranks.
5. **Collective operation**: an operation involving all processes in a communicator (broadcast, reduce, scatter, gather, all-to-all). Collectives are highly optimized by MPI implementations and are usually faster than hand-written equivalents using point-to-point.

## A first program

```c
#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    printf("Hello from rank %d of %d\n", rank, size);

    MPI_Finalize();
    return 0;
}
```

Compile and run:

```bash
mpicc hello.c -o hello
mpirun -n 4 ./hello
```

Output:

```
Hello from rank 2 of 4
Hello from rank 0 of 4
Hello from rank 1 of 4
Hello from rank 3 of 4
```

(The order is unspecified — they're concurrent processes, racing to stdout.)

## Point-to-point: send and receive

```c
if (rank == 0) {
    int data = 42;
    MPI_Send(&data, 1, MPI_INT, 1, 0, MPI_COMM_WORLD);
} else if (rank == 1) {
    int data;
    MPI_Status status;
    MPI_Recv(&data, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, &status);
    printf("Got %d\n", data);
}
```

Six-argument send: buffer, count, type, destination, tag, communicator. Same shape for receive. The tag and types let MPI match heterogeneous sends with the right receives. The status object reports who actually sent (useful when you receive with `MPI_ANY_SOURCE`).

`MPI_Send` is a *blocking* send. It returns when the buffer is safe to reuse — which may be after the message is copied to a system buffer (immediate), or after it's actually delivered to the destination (deferred). The standard does not require either; the implementation chooses based on message size and resource availability. This subtlety bites everyone at least once.

For known-async behavior, use `MPI_Isend` / `MPI_Irecv` (immediate, returns instantly with a handle you `MPI_Wait` on later).

## Collectives: where the speed lives

A common pattern: every process computes a partial sum, you want the global sum.

```c
double local = compute_partial();
double total;
MPI_Reduce(&local, &total, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);
// rank 0 now has total
```

MPI implementations turn this into a $O(\log P)$ tree reduction, sometimes hardware-accelerated by network collectives such as Mellanox/NVIDIA SHARP or HPE Cray collective offload. Related GPU libraries such as NCCL do the same kind of topology-aware collective optimization inside accelerator-heavy nodes and clusters. Hand-rolling this with point-to-point is often much slower because you can't see the topology of the network and the implementation can.

Other essentials:

- `MPI_Bcast(buf, ..., root, comm)` — root sends to all
- `MPI_Scatter` — root distributes a array, each rank gets a slice
- `MPI_Gather` — opposite of scatter
- `MPI_Allreduce` — reduce, but all ranks see the result
- `MPI_Alltoall` — every-to-every transpose, the bandwidth-killer

## Worked example: 1D heat equation

Domain: 1D bar, length 1, divided into N grid points. Update rule: each step, every interior point becomes the average of itself and its two neighbors. Run T steps.

The parallelization: divide the grid into P contiguous chunks, one per rank. Each step:

1. Exchange "halo" cells with left and right neighbors.
2. Update interior of own chunk.
3. Repeat T times.

```c
// pseudocode
int local_n = N / size;
double *u  = malloc((local_n + 2) * sizeof(double));   // +2 for halo cells
double *un = malloc((local_n + 2) * sizeof(double));

for (int t = 0; t < T; t++) {
    // Halo exchange
    int left  = (rank - 1 + size) % size;
    int right = (rank + 1) % size;
    MPI_Sendrecv(&u[1],         1, MPI_DOUBLE, left,  0,
                 &u[local_n+1], 1, MPI_DOUBLE, right, 0,
                 MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    MPI_Sendrecv(&u[local_n],   1, MPI_DOUBLE, right, 0,
                 &u[0],         1, MPI_DOUBLE, left,  0,
                 MPI_COMM_WORLD, MPI_STATUS_IGNORE);

    // Update interior
    for (int i = 1; i <= local_n; i++)
        un[i] = 0.5 * u[i] + 0.25 * (u[i-1] + u[i+1]);

    // Swap pointers
    double *tmp = u; u = un; un = tmp;
}
```

This is the canonical MPI program. Halo exchange + local update + repeat. Three-quarters of every climate model, every CFD code, every reservoir simulator on Earth is doing some version of this, in 3D, with more variables, with more sophisticated communication overlap. But the bones are the same.

## The performance model: alpha-beta

A typical message passing cost model:

$$T_{message}(n) = \alpha + n \cdot \beta$$

where:
- $\alpha$ is the per-message latency (in seconds): bus traversals, software overheads, hardware tag matching. On a modern InfiniBand fabric, ~1 µs.
- $\beta$ is the per-byte transfer cost (s/byte): inverse of bandwidth. At 200 Gb/s, ~40 ps/byte.

For small messages, $\alpha$ dominates. For large messages, $\beta$ dominates. The crossover is at $n^* = \alpha/\beta$, in our example ~25 KB.

This drives much of MPI program design: aggregate small messages, hide latency by overlapping computation with communication, choose collective patterns whose tree depth fits the cost model. A program that does $10^6$ tiny messages per step will be ruined by $\alpha$; the same program restructured to do $10^3$ medium messages per step will be limited by $\beta$, which is much closer to peak bandwidth.

## What MPI is *not*

- **Not a thread library.** Each MPI rank is typically a separate process. Threading inside a rank is your problem, usually with OpenMP. The hybrid "MPI + OpenMP" pattern is standard.
- **Not a runtime.** MPI doesn't dynamically schedule work, balance load, or handle failures gracefully. You do those.
- **Not opinionated about data layout.** Every rank holds whatever arrays you tell it to. The `MPI_Type_*` machinery lets you describe non-contiguous data, but you have to do the describing.

These omissions are why MPI has lasted thirty years and why it gets criticized regularly. The *minimal* design is the reason it worked across heterogeneous hardware. It's also the reason that writing a fault-tolerant, dynamically-load-balanced MPI program is hard.

## Lab — MPI on your laptop

`labs/09-mpi-stencil/` contains a complete buildable 1D heat-equation solver in MPI. We use **MPICH** (free, easy to install on macOS via Homebrew or on Linux via package manager). On a laptop you typically run it as:

```bash
mpicc heat1d.c -O3 -o heat1d
mpirun -n 4 ./heat1d 10000 1000
```

The lab walks you through:
1. Verifying that 1, 2, 4, 8 ranks all produce the same answer.
2. Measuring strong scaling (fixed problem, more ranks).
3. Measuring weak scaling (problem grows with ranks).
4. Modifying the code to overlap halo exchange with interior computation using `MPI_Isend`/`MPI_Irecv`.

Even on a laptop you'll see real scaling effects — and you'll see strong scaling break down at high rank counts as $\alpha$ overwhelms the per-rank work.

## Discussion questions

1. MPI has thousands of functions but a tiny conceptual core. Pick a *different* successful API standard (POSIX, OpenGL, S3) and identify *its* conceptual core. What's similar? What's different about HPC that justifies MPI's particular shape?
2. MPI requires explicit data marshalling — you say which buffers go where. Modern accelerator APIs (CUDA Unified Memory, SYCL USM) are moving toward implicit data movement. Is implicit data movement obviously better? What does it cost, and what does it gain?
3. MPI is not fault-tolerant: if one rank dies, the whole job dies. At exascale, mean time between hardware failures can be hours. How does the HPC ecosystem currently work around this? (Hint: BLCR, DMTCP, application-level checkpoints, MPI ULFM.)

## Further reading

- Gropp, Lusk & Skjellum (2014). [*Using MPI: Portable Parallel Programming with the Message-Passing Interface*](https://mitpress.mit.edu/9780262527392/using-mpi/), 3rd ed. The textbook.
- [The MPI Standard](https://www.mpi-forum.org/docs/) itself. Free PDF. Treat it like a reference, not bedside reading.
- Snir, M. et al. (1996). [*MPI: The Complete Reference*](https://mitpress.mit.edu/9780262691840/mpi-the-complete-reference-volume-1/). The MPI-1 era reference, useful for understanding why things ended up the way they did.
- The MPI Forum minutes are public. The 1992–94 minutes are a fascinating record of how a successful standardization process actually negotiates trade-offs.
