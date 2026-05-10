#!/bin/bash
#SBATCH --account=PROJ123                # project allocation, required
#SBATCH --job-name=hipmpi
#SBATCH --nodes=64                        # 64 Frontier nodes
#SBATCH --ntasks-per-node=8               # 8 MPI ranks per node = 1 per GCD
#SBATCH --gpus-per-node=8                 # 8 GCDs per node (4 MI250X * 2 GCDs)
#SBATCH --cpus-per-task=7                 # 7 threads per rank (56 cores / 8)
#SBATCH --time=01:00:00
#SBATCH --output=hipmpi-%j.out
#SBATCH --partition=batch

# Load the AMD HIP/ROCm module and Cray MPICH
module load craype-accel-amd-gfx90a
module load PrgEnv-amd
module load rocm/5.7

# Slingshot tuning
export MPICH_OFI_NIC_POLICY=NUMA          # bind NICs by NUMA domain
export MPICH_GPU_SUPPORT_ENABLED=1        # GPU-aware MPI (RDMA from HBM)

# Map MPI ranks to specific GCDs (manual binding)
export ROCR_VISIBLE_DEVICES=$SLURM_LOCALID

srun --cpu-bind=cores ./my_app
