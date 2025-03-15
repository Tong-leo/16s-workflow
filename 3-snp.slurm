#!/bin/bash 
#SBATCH -J snp
#SBATCH -o /dm_data/tongjw/20250306-anti/log/snp_out_%A_%a.out
#SBATCH -e /dm_data/tongjw/20250306-anti/log/snp_error_%A_%a.error
#SBATCH -p dm_pub_cpu
#SBATCH -N 1
#SBATCH -n 32
#SBATCH --time=3-00:00:00
#SBATCH --array=1-112


cd /dm_data/tongjw/20250306-anti

mkdir cross_match

start_index=$(( (SLURM_ARRAY_TASK_ID - 1) * 100 + 1 ))
end_index=$(( SLURM_ARRAY_TASK_ID * 100 ))

# 获取文件列表中的对应文件
sed -n "${start_index},${end_index}p" filter_id.txt | while read -r file; do
	base=$(basename $file)
	seqkit grep -f "./degap/${base%_filter_id.txt}_filter_id.txt" "./degap/${base%_filter_id.txt}.ng.fasta" -o "./cross_match/${base%_filter_id.txt}_cross_input.fasta"
	usearch -fastx_uniques "./cross_match/${base%_filter_id.txt}_cross_input.fasta" -fastaout "./cross_match/${base%_filter_id.txt}_dereplicated.fasta" -sizeout
	seqkit head -n 1 "./cross_match/${base%_filter_id.txt}_dereplicated.fasta" > "./cross_match/${base%_filter_id.txt}_template.fasta"
	/home_data/home/spst/tongjw2024/software/crossmatch/cross_match -discrep_lists -tags -masklevel 0 -minscore 1200 -alignments "./cross_match/${base%_filter_id.txt}_cross_input.fasta" "./cross_match/${base%_filter_id.txt}_template.fasta" > "./cross_match/${base%_filter_id.txt}_cross_match.txt"
	python /home_data/home/spst/tongjw2024/code/summary.py "./cross_match/${base%_filter_id.txt}_cross_match.txt" "./cross_match/${base%_filter_id.txt}_template.fasta" "./cross_match/${base%_filter_id.txt}_cross_match_summary.txt"
	python /home_data/home/spst/tongjw2024/code/2tsv.py "./cross_match/${base%_filter_id.txt}_cross_match_summary.p"
	python /home_data/home/spst/tongjw2024/code/cross_summary.py "./cross_match/${base%_filter_id.txt}_cross_match_summary.p.tsv"
	rm "./cross_match/${base%_filter_id.txt}_dereplicated.fasta"
	rm "./cross_match/${base%_filter_id.txt}_cross_match.txt"
	rm "./cross_match/${base%_filter_id.txt}_cross_match_summary.txt"
	rm "./cross_match/${base%_filter_id.txt}_cross_input.fasta.log"
	rm "./cross_match/${base%_filter_id.txt}_cross_match_summary.p"
	rm "./cross_match/${base%_filter_id.txt}_cross_match_summary.p.tsv"
done
