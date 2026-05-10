#!/bin/bash
#SBATCH --job-name=heat1d
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=2
#SBATCH --time=00:05:00
#SBATCH --output=heat1d-%j.out

mpirun ./heat1d 8000000 1000
