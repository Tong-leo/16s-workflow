#!/bin/bash 
#SBATCH -J get
#SBATCH -o /dm_data/tongjw/20250306-anti/log/get_out
#SBATCH -e /dm_data/tongjw/20250306-anti/log/get_error
#SBATCH -p dm_debug
#SBATCH -N 1
#SBATCH -n 32
#SBATCH --time=1-00:00:00


cd /dm_data/tongjw/20250306-anti
mkdir msa
ls ./cross_match/*_cross_input.fasta > fasta.txt

python /home_data/home/spst/tongjw2024/code/get_snp.py ./passed/ ./failed/


