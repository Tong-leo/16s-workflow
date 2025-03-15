import pandas as pd
from Bio import AlignIO
import os
from collections import Counter

# 读取pos.tsv文件
pos_df = pd.read_csv("pos.tsv", sep="\t")

# 读取filter_align.xlsx文件
data_df = pd.read_excel("filter_align.xlsx")

# 构建base_pos列表
base_pos = []
for pos in pos_df['pos']:
    for base in ['A', 'T', 'C', 'G', '-']:
        base_pos.append(f"{pos}_{base}")

# 创建初始的DataFrame
num_samples = len(data_df)
p_df = pd.DataFrame(0, index=base_pos, columns=data_df['cell'])

# Function to calculate base percentages
def get_base(template_seq, ref_seqs, target_pos):
    index = next((i for i, record in enumerate(ref_seqs) if record.id.split(';')[0] == template_seq.id.split(';')[0]), None)
    if index is None:
        return [0] * 5

    ref_seq_str = str(ref_seqs[index].seq)
    
    count = -1
    ali_pos = None
    for i, char in enumerate(ref_seq_str):
        if char != "-":
            count += 1
        if count == target_pos:
            ali_pos = i
            break  
    
    if ali_pos is None:
        return [0] * 5
    
    column_bases = [str(seq_record.seq[ali_pos]).lower() for seq_record in ref_seqs]
    base_counter = Counter(column_bases)

    all_count = len(column_bases)
    result = [
        round(base_counter.get('a', 0) * 100 / all_count, 2),
        round(base_counter.get('t', 0) * 100 / all_count, 2),
        round(base_counter.get('c', 0) * 100 / all_count, 2),
        round(base_counter.get('g', 0) * 100 / all_count, 2),
        round(base_counter.get('-', 0) * 100 / all_count, 2)
    ]

    return result

# 读template和ref文件，并计算
sto_pos_list = pos_df['pos'].tolist()

for i, row in data_df.iterrows():
    sample_name = row['cell']
    template_file = f"../cross_match/out_{sample_name}_template.fasta"
    ref_file = f"../msa/out_{sample_name}_msa.fasta"

    # 加载对齐的FASTA文件
    template_alignment = AlignIO.read(template_file, "fasta")
    ref_alignment = AlignIO.read(ref_file, "fasta")

    # 使用第一个序列作为template
    template_seq = template_alignment[0]

    for index, t_p in enumerate(sto_pos_list):
        base_pos_index_start = index * 5
        base_pos_index_end = base_pos_index_start + 5

        p_df.iloc[base_pos_index_start:base_pos_index_end, i] = get_base(template_seq, ref_alignment, t_p)

# 输出结果到TSV文件
p_df.to_csv("output.tsv", sep='\t', index_label='Base_Positions')