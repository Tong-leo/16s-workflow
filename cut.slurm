#!/bin/bash 
#SBATCH -J cut
#SBATCH -o /dm_data/tongjw/20250306-anti/log/cut_out
#SBATCH -e /dm_data/tongjw/20250306-anti/log/cut_error
#SBATCH -p dm_pub_cpu
#SBATCH -N 1
#SBATCH -n 32
#SBATCH --time=3-00:00:00


cd /dm_data/tongjw/20250306-anti

source ~/.bashrc
conda activate cap
python /home_data/home/spst/tongjw2024/code/statistical_bbmap.py -i /dm_data/tongjw/20250306-anti/corrected/ -o /dm_data/tongjw/20250306-anti -s 200

conda deactivate

mkdir bbmap_output_many_seqs_cut

input_folder="/dm_data/tongjw/20250306-anti/bbmap_output_many_seqs/" 
output_folder="/dm_data/tongjw/20250306-anti/bbmap_output_many_seqs_cut/" 

for fasta_file in "$input_folder"/*.fasta; do

    filename=$(basename "$fasta_file" .fasta)
	
	cutadapt -g "AGAGTTTGATCATGGCTCAG;min_overlap=19...AAGTCGTAACAAGGTAGCCGTA;min_overlap=19" --action=retain --cores 32 -e 0.15 --discard-untrimmed -o "$output_folder/$filename.fasta" "$input_folder/$filename.fasta"

done

echo "Processing completed."