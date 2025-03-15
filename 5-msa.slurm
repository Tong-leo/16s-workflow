#!/bin/bash 
#SBATCH -J msa
#SBATCH -o /dm_data/tongjw/20250306-anti/log/msa_out_%A_%a
#SBATCH -e /dm_data/tongjw/20250306-anti/log/msa_error_%A_%a
#SBATCH -p dm_pub_cpu
#SBATCH -N 1
#SBATCH -n 32
#SBATCH --time=3-00:00:00
#SBATCH --array=1-112



cd /dm_data/tongjw/20250306-anti

start_index=$(( (SLURM_ARRAY_TASK_ID - 1) * 100 + 1 ))
end_index=$(( SLURM_ARRAY_TASK_ID * 100 ))

# 获取文件列表中的对应文件
sed -n "${start_index},${end_index}p" fasta.txt | while read -r file; do
	base=$(basename $file)

	mafft --auto --thread 8 $file > "./msa/${base%_cross_input.fasta}_msa.fasta"
done
