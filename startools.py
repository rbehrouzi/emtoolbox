import pandas as pd
import numpy as np
def dfToStar(full_filename, data_table, conversion_dict={}):
# write pandas dataframe as start file
# if a conversion dictionary is provided, table column headers are converted accordingly
    if not full_filename.endswith(".star"):
        full_filename += ".star"
    with open(full_filename, 'w') as f:
        f.write('\n')
        f.write("data_" + '\n')
        f.write('\n')
        f.write("loop_" + '\n')
        for i in range(len(data_table.columns)):
            if conversion_dict: #empty dict is False
                line = conversion_dict[data_table.columns[i]] + " \n"
            else:
                line = data_table.columns[i] + "\n"
            line = line if line.startswith('_') else '_' + line
            f.write(line)

    data_table.to_csv(full_filename, mode='a', sep=' ', header=False, index=False)
    return

def starToDf (full_filename):
# read star file containing one data block into pandas dataframe
# returns dataframe
    headers = []
    lineskip_count=0
    reading_labels=False

    with open(full_filename) as f:
        # count header lines and store column headers
        for line in f:
            if line[0:4] == "_rln":
                reading_labels = True
                params = line.split()
                headers.append(params[0])
            else:
                # has the labels been read
                if reading_labels:
                    break
            lineskip_count += 1
        
        starDf= pd.read_table(full_filename, delimiter=' ', header=None, index_col=False,
                    skipinitialspace=True, skiprows=lineskip_count,
                    names=headers)
    return starDf

star_file="particles.star"
list_file="samr4_particles_ingoodclasses.plt"
selection_file="particles_selected.star"
selected_rows=[]

with open(list_file) as f:
    for line in f:
        selected_rows.append(int(line)-1) #convert to zero-based index

alldata_df=starToDf(star_file)
dfToStar(selection_file, alldata_df.loc[selected_rows,:]) 