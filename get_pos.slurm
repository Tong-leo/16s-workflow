#!/bin/bash 
#SBATCH -J pos
#SBATCH -o /dm_data/tongjw/20241226-ZJ/log/pos_out
#SBATCH -e /dm_data/tongjw/20241226-ZJ/log/pos_error
#SBATCH -p dm_pub_cpu
#SBATCH -N 1
#SBATCH -n 32
#SBATCH --time=3-00:00:00


cd /dm_data/tongjw/20241226-ZJ/snp

python get_pos.py


