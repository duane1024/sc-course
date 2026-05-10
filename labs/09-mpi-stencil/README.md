# Lab 09 — MPI 1D Heat Equation

A canonical distributed-memory MPI program: 1D heat equation by halo exchange. Strong-scale and weak-scale on your laptop.

## Prerequisites

Install MPICH or OpenMPI:

- macOS: `brew install mpich` or `brew install open-mpi`
- Debian/Ubuntu: `sudo apt-get install mpich libmpich-dev`
- Fedora/RHEL: `sudo dnf install mpich mpich-devel` (then `module load mpi/mpich`)

Verify: `mpicc --version` and `mpirun --version`.

## Build and run

```bash
make
mpirun -n 4 ./heat1d 1000000 1000
```

Arguments: grid size, number of timesteps.

## Exercises

### 1. Verify correctness

Run with 1, 2, 4, 8 ranks. The final printed L2 norm should be identical (or differ only at the last few digits, due to non-associative floating-point reduction order).

### 2. Strong scaling

Fix problem size at `N = 4_000_000`. Run with 1, 2, 4, 8 ranks. Plot wall-clock vs. rank count. Above some rank count, you'll see scaling fall off — when the per-rank work is small enough that halo exchange dominates.

### 3. Weak scaling

Fix per-rank size at `N_per_rank = 500_000`. Run with 1, 2, 4, 8 ranks (so total `N` grows). Wall clock should be flat under perfect weak scaling. It won't be flat — explain the deviation.

### 4. Overlap

Modify `heat1d.c` to use `MPI_Isend`/`MPI_Irecv` and overlap the halo exchange with the interior update (compute interior cells while waiting for halos to arrive, then update edge cells). Re-measure strong scaling. The improvement at high rank count should be visible.
