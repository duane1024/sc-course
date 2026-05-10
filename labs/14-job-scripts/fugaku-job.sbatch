#!/bin/bash
# Fugaku uses Fujitsu's "pjsub" job system. Translated to look Slurm-like
# for pedagogy. The real syntax is `pjsub` with `#PJM` directives.
#PJM -L "node=512"                        # 512 A64FX nodes
#PJM -L "rscgrp=large"
#PJM -L "elapse=01:00:00"
#PJM --mpi "max-proc-per-node=4"          # 4 ranks per node (NUMA domains)
#PJM -j

# A64FX module
module load fujitsu/4.10
module load mpi

# A64FX SVE-512 vector tuning. Two threads of SVE per rank.
export OMP_NUM_THREADS=12                 # 12 cores per rank, 48/4
export FLIB_BARRIER=HARD                   # spin-wait at barriers
export FLIB_SCCR_CNTL=TRUE                 # SCCR optimizations
export FLIB_HPCFUNC=YES                    # HPC math library overrides

mpiexec -np 2048 ./my_app                 # 4 ranks per node * 512 nodes
