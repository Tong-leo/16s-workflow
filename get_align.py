import os
import sys

def process_file_genus(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()[1:]  # 跳过第一行标题
    # 提取每一行的 genus 和 freq，并格式化为 genus_freq
    entries = [f"{line.split()[0]}_{line.split()[1]}" for line in lines if line.strip()]
    return ";".join(entries)

def process_file_species(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()[1:]  # 跳过第一行标题
    # 提取每一行的 species 和 freq，并格式化为 genus_freq
    entries = ["{}_{}".format(line.split('\t')[0].strip(), line.split('\t')[1].strip()) for line in lines if line.strip()]
    return ";".join(entries)

def main(folder_path):
    output_file = "align_genus_stat.txt"
    with open(output_file, 'w') as genus:
        for root, dirs, files in os.walk(folder_path):
            for file in files:
                if file.endswith('align_genus'):
                    file_path = os.path.join(root, file)
                    result = f"{file}:{process_file_genus(file_path)}"
                    genus.write(result + "\n")
                    
    output_file = "align_species_stat.txt"
    with open(output_file, 'w') as species:
        for root, dirs, files in os.walk(folder_path):
            for file in files:
                if file.endswith('align_species'):
                    file_path = os.path.join(root, file)
                    result = f"{file}:{process_file_species(file_path)}"
                    species.write(result + "\n")
                    
if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <folder_path>")
    else:
        folder_path = sys.argv[1]
        main(folder_path)