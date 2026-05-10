# Lab 10 — Mini cluster on your laptop

Run a real Slurm + MPI workflow on Docker containers that act as compute nodes.

## Prerequisites

- Docker
- ~2 GB free RAM

## Set up

```bash
docker compose up -d
```

This brings up:
- 1 head node (`headnode`) with `slurmctld` and a shared NFS volume.
- 4 compute nodes (`node[01-04]`) running `slurmd` and `mpich`.

## Run a job

```bash
docker exec -it headnode bash
cd /shared
sbatch hello.sbatch
squeue
cat slurm-*.out
```

Then submit the heat equation from lab 09:

```bash
cp /shared/labs/09-mpi-stencil/heat1d.c .
mpicc -O3 heat1d.c -o heat1d
sbatch heat1d.sbatch
```

## Tear down

```bash
docker compose down -v
```

## What you've just done

You've run a multi-node distributed-memory MPI job, scheduled by Slurm, with a shared filesystem, on architecture identical to a Top500 system at *much* smaller scale. The architectural pattern Beowulf invented in 1994 is what your laptop just ran.

## Files

- `docker-compose.yml`: 5-container layout
- `hello.sbatch`: example Slurm job script
- `heat1d.sbatch`: real MPI job
