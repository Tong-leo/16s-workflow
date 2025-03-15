import pandas as pd
import os
import argparse

def process_alignment_file(infile, tax_file):
    # 读取输入文件和分类文件
    align = pd.read_table(infile, sep="\t", header=0)
    tax = pd.read_table(tax_file, sep="\t", header=None)

    # 过滤 tax 文件，保留 TemplateName 在 align 中的部分
    tax = tax[tax[0].isin(align['TemplateName'].unique())]

    # 提取 genus 信息
    tax[7] = tax[1].apply(lambda x: x.split(";")[5])
    tax = tax[[0, 4, 7]]
    tax.columns = ["TemplateName","species","genus"]

    # 合并 align 和 tax 数据
    align = pd.merge(align, tax, on="TemplateName", how="left")

    # 计算并输出 genus 的频率
    genus_count = align['genus'].value_counts().reset_index()
    genus_count.columns = ['genus', 'Freq']
    outfile = infile.replace("align_report", "align_genus")
    genus_count.to_csv(outfile, sep="\t", index=False, header=True, quoting=False)

    # 筛选 SearchScore > 90 的行
    align_filtered = align[align['SearchScore'] > 90]
    if align_filtered.empty:
        return
    
    # 计算并输出筛选后的 genus 的频率
    genus_count_filtered = align_filtered['genus'].value_counts().reset_index()
    genus_count_filtered.columns = ['genus', 'Freq']
    outfile_filtered = infile.replace("align_report", "filter_align_genus")
    genus_count_filtered.to_csv(outfile_filtered, sep="\t", index=False, header=True, quoting=False)


    species_count_filtered = align_filtered['species'].value_counts().reset_index()
    species_count_filtered.columns = ['species', 'Freq']
    outfile_filtered = infile.replace("align_report", "filter_align_species")
    species_count_filtered.to_csv(outfile_filtered, sep="\t", index=False, header=True, quoting=False)




    # 获取具有最大频率的 genus 的 QueryName
    max_genus = genus_count_filtered.loc[genus_count_filtered['Freq'].idxmax(), 'genus']
    filtered_ids = align_filtered[align_filtered['genus'] == max_genus]['QueryName']

    # 输出筛选后的 ID
    outfile_ids = infile.replace(".align_report", "_filter_id.txt")
    filtered_ids.to_csv(outfile_ids, index=False, header=False, quoting=False)

if __name__ == "__main__":
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Process alignment files in a specified folder.')
    parser.add_argument('folder_path', type=str, help='The path to the folder containing alignment files.')
    args = parser.parse_args()

    # Input file path
    tax_file = "/dm_data/tongjw/ref/silva/tax.tsv"
    folder_path = args.folder_path
    file_extension = '.align_report'
    
    for filename in os.listdir(folder_path):
        if filename.endswith(file_extension):
            file_path = os.path.join(folder_path, filename)
            process_alignment_file(file_path, tax_file)
            
