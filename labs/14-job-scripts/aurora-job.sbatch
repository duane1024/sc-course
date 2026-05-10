#!/bin/bash
# Aurora uses PBS, not Slurm. This is a translation; ANL's actual job
# script syntax differs. Uses qsub flags but kept similar to Slurm for
# pedagogy. See ANL's documentation for the real form.
#PBS -A proj123
#PBS -N syclmpi
#PBS -l select=128                        # 128 Aurora nodes
#PBS -l walltime=01:00:00
#PBS -q prod
#PBS -k doe

cd $PBS_O_WORKDIR
module load oneapi
module load mpich

# Aurora has 6 GPUs per node, each with 2 tiles = 12 tile slots per node
NRANKS_PER_NODE=12
NDEPTH=8
NTHREADS=4

# SYCL device selection
export ZE_AFFINITY_MASK=0.0,0.1,1.0,1.1,2.0,2.1,3.0,3.1,4.0,4.1,5.0,5.1
export FI_CXI_DEFAULT_CQ_SIZE=131072       # large CQ for many ranks

mpiexec -np $((NRANKS_PER_NODE * 128)) --ppn $NRANKS_PER_NODE \
        --depth=$NDEPTH --cpu-bind depth ./my_app
