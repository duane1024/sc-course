# Lab 14 — Read a real Slurm job script

Three production Slurm scripts, drawn from public documentation, for Frontier (ORNL), Aurora (ANL), and Fugaku (RIKEN). Heavy comments. Read them; you don't run them.

Files:

- `frontier-job.sbatch` — typical Frontier MPI+HIP job
- `aurora-job.sbatch` — typical Aurora MPI+SYCL job
- `fugaku-job.sbatch` — typical Fugaku MPI+OpenMP job (no GPU)

## Exercises

1. For each script, identify the architectural assumption baked in: per-node accelerator count, the launcher (`srun`, `mpiexec`, `pjsub`), and any vendor-specific environment variables.
2. Adapt one of the scripts to run on the mini cluster from Lab 10. Most lines should be deletable; the ones that remain are the architecturally generic ones.
3. Pick one site-specific tuning flag (e.g., `MPICH_OFI_NIC_POLICY`, `FI_CXI_DEFAULT_CQ_SIZE`, `SBATCH_PROFILE`) and look up what it does. Most are documented in the site's user guide. Most could not have existed before 2015.
