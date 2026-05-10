#!/bin/bash
#SBATCH --job-name=hello
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=2
#SBATCH --time=00:01:00
#SBATCH --output=hello-%j.out

mpirun ./hello
