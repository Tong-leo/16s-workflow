#!/bin/bash 
#SBATCH -J merge
#SBATCH -o /dm_data/tongjw/20250306-anti/log/merge_out
#SBATCH -e /dm_data/tongjw/20250306-anti/log/merge_error
#SBATCH -p dm_pub_cpu
#SBATCH -N 1
#SBATCH -n 32
#SBATCH --time=3-00:00:00


cd /dm_data/tongjw/20250306-anti

#!/bin/bash

# 定义源文件夹和目标文件夹
folder1="bbmap_output_match1"
folder2="bbmap_output_match2"
merged_dir="merge"

# 创建目标目录
mkdir -p "$merged_dir"

# 处理folder1中的文件
find "$folder1" -type f -print0 | while IFS= read -r -d '' file; do
    # 获取相对路径和文件名
    rel_path="${file#$folder1/}"
    target_file="$merged_dir/$rel_path"
    
    # 如果folder2中存在同名文件，则合并
    if [ -f "$folder2/$rel_path" ]; then
		seqkit seq -p -r -t DNA "$folder2/$rel_path" > tmp.fasta
        cat "$file" tmp.fasta > "$target_file"
		rm tmp.fasta
    else
        cp "$file" "$target_file"
    fi
done

# 处理folder2中的独有文件
find "$folder2" -type f -print0 | while IFS= read -r -d '' file; do
    rel_path="${file#$folder2/}"
    target_file="$merged_dir/$rel_path"
    
    # 仅当folder1中不存在该文件时复制
    if [ ! -f "$folder1/$rel_path" ]; then
		seqkit seq -p -r -t DNA "$folder2/$rel_path" > tmp.fasta
        cp tmp.fasta "$target_file"
    fi
done

cd /dm_data/tongjw/20250306-anti

source ~/.bashrc
conda activate cap
python /home_data/home/spst/tongjw2024/code/statistical_bbmap.py -i /dm_data/tongjw/20250306-anti/merge/ -o /dm_data/tongjw/20250306-anti -s 200
conda deactivate

cd /dm_data/tongjw/20250306-anti
mkdir corrected

input_folder="/dm_data/tongjw/20250306-anti/bbmap_output_many_seqs/" 
output_folder="/dm_data/tongjw/20250306-anti/corrected/" 

for fastq_file in "$input_folder"/*.fastq; do

    filename=$(basename "$fastq_file" .fastq)

    seqkit fq2fa "$input_folder/$filename.fastq" -o "$filename.fasta"

    /home_data/home/spst/tongjw2024/software/rust-msbwt/target/release/msbwt2-build -o "$filename.msbwt.npy" "$filename.fasta"

    /home_data/home/spst/tongjw2024/software/fmlrc2/target/release/fmlrc2 "$filename.msbwt.npy" "$filename.fasta" "$filename.corrected.fasta"

    cp "$filename.corrected.fasta" "$output_folder/$filename.fasta"
    
    # 可选：删除中间文件以节省空间
    rm "$filename.fasta" "$filename.msbwt.npy" "$filename.corrected.fasta"
done

mkdir bbmap_output_many_seqs_cut

input_folder="/dm_data/tongjw/20250306-anti/corrected/" 
output_folder="/dm_data/tongjw/20250306-anti/bbmap_output_many_seqs_cut/" 

for fasta_file in "$input_folder"/*.fasta; do

    filename=$(basename "$fasta_file" .fasta)
	
	cutadapt -g "AGAGTTTGATCATGGCTCAG;min_overlap=19...AAGTCGTAACAAGGTAGCCGTA;min_overlap=19" --action=retain --cores 32 -e 0.15 --discard-untrimmed -o "$output_folder/$filename.fasta" "$input_folder/$filename.fasta"

done

echo "Processing completed."
