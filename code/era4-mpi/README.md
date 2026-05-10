# Era 4 — MPI (Cray T3E, 1995 → every cluster since)

Distributed-memory SAXPY. Each rank owns a slice of `x` and `y`, computes its local part with no inter-rank communication (SAXPY is embarrassingly parallel), then participates in a reduction at the end to verify.

## Build and run

```bash
mpicc -O3 -march=native saxpy_mpi.c -o saxpy_mpi
mpirun -n 4 ./saxpy_mpi
```

## What's bigger here

The kernel logic is two lines. The MPI scaffolding (init, finalize, rank lookup, allocation by rank, reduction) is twenty. This is *normal*: MPI's costs are mostly fixed, and they're paid once whether your kernel is SAXPY or a 30-stage atmospheric model.

## What's notable

Real applications — climate, CFD, materials — spend most of their MPI complexity on **halo exchange** (which SAXPY doesn't need) and **collective communication patterns**. The lab in Week 9 (`labs/09-mpi-stencil/`) shows halo exchange. SAXPY-in-MPI is the simple case.
