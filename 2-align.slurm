#!/bin/bash 
#SBATCH -J align
#SBATCH -o /dm_data/tongjw/20250306-anti/log/align_out_%A_%a.out
#SBATCH -e /dm_data/tongjw/20250306-anti/log/align_error_%A_%a.error
#SBATCH -p dm_pub_cpu
#SBATCH -N 1
#SBATCH -n 32
#SBATCH --time=3-00:00:00
#SBATCH --array=1-112

source ~/.bashrc
conda activate mothur

cd /dm_data/tongjw/20250306-anti

mkdir degap
total_lines=$(wc -l < file_list.txt)  # 获取总行数
group_size=1000                       # 每次处理的行数
output_prefix="tmp_"               # 合并文件的前缀

for ((i=1; i<=total_lines; i+=group_size)); do
  file_group=$(sed -n "${i},$((i+group_size-1))p" file_list.txt)
  group_index=$(( (i - 1) / group_size + 1 ))
  printf "$output_file\n"
  for file in ${file_group}; do
    cat "./bbmap_output_many_seqs_cut/$file" >> tmp.fasta
  done

  mothur "#align.seqs(fasta=tmp.fasta,reference=/dm_data/tongjw/ref/silva/silva.nr_v138_2.align,threshold=0.5)"
  mothur "#degap.seqs(fasta=tmp.align)"

  rm -rf tmp.fasta
  rm -rf tmp.align
  rm -rf ./*.logfile

  python /home_data/home/spst/tongjw2024/code/align_fasta_split.py 
  python /home_data/home/spst/tongjw2024/code/align_report_split.py
  
  rm -rf tmp.ng.fasta
  rm -rf tmp.align_report
done

conda deactivate

python /home_data/home/spst/tongjw2024/code/filter_id.py ./degap/
python /home_data/home/spst/tongjw2024/code/get_align.py ./degap/
ls ./degap/*_filter_id.txt > filter_id.txt

dir="/dm_data/tongjw/20250306-anti/bbmap_output_many_seqs_cut/" 

mkdir minimap2_output_many_seqs

for file in ${dir}*.fasta
do 
    base=$(basename $file)
    echo "Processing $base" 

    minimap2 -ax map-ont --secondary=no ./16s_ref.fasta "$file" > "./minimap2_output_many_seqs/${base%.fasta}_minimap2_output.txt"

done

python /home_data/home/spst/tongjw2024/code/purity.py ./minimap2_output_many_seqs ./purity_minimap2.txt ./purity_minimap2.jpg

