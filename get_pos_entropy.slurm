#!/bin/bash 
#SBATCH -J entropy
#SBATCH -o /dm_data/tongjw/20241226-ZJ/log/entropy_out
#SBATCH -e /dm_data/tongjw/20241226-ZJ/log/entropy_error
#SBATCH -p dm_debug
#SBATCH -N 1
#SBATCH -n 32
#SBATCH --time=1-00:00:00


cd /dm_data/tongjw/20241226-ZJ/snp

python get_pos_entropy.py


