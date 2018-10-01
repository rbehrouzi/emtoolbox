import pandas as pd
import sqlite3
import os


def dbToStar(full_filename, data_table, conversion_dict={}, reindex=False):
# write pandas table as start file
# if a conversion dictionary is provided, table column headers are converted accordingly
# TODO: use startool write db

    if not full_filename.endswith(".star"):
        full_filename += ".star"
    with open(full_filename, 'w') as f:
        f.write('\n')
        f.write("data_images" + '\n')
        f.write('\n')
        f.write("loop_" + '\n')
        for i in range(len(data_table.columns)):
            if conversion_dict.isempty():
                line = data_table.columns[i] + "\n"
            else:
                line = conversion_dict[data_table.columns[i]] + " \n"
            line = line if line.startswith('_') else '_' + line
            f.write(line)
    data_table.to_csv(full_filename, mode='a', sep=' ', header=False, index=False)

def starToDb (full_filename):
# read star file into database
    with open(full_filename) as f:
        # Walk through line by line
        name = ""
        labels = []
        data = []
        mode = ""
        # Get the data
        rr = f.read().splitlines()
        l = len(rr)
        for line in rr:
            if line[0:5] == "data_":
                # gets the table name
                name = line
            elif line[0:5] == "loop_":
                # gets into a loop thing and tells the program to expect just labels
                mode = "labels"
            elif line[0:4] == "_rln":
                if mode == "labels": # get normal labels here
                    params = line.split()
                    labels.append(params[0])
                else:
                # labels also hava data just behind
                    params = line.split()
                    labels.append(params[0])
                    if len(data) == 0:
                        data.append([])
                    data[0].append(params[1])
                    # since data came, set the mode
                    mode = "data"
            elif line == "":
                # emtpy row, closes table if data was read before
                if mode == "data":
                    self.makeTable(full_filename, name, labels, tuple(data))
                    # Unset all the vars
                    name = ""
                    labels = []
                    data = []
                    mode = ""
            else:
                # mode has to be labels or data before
                if mode == "labels" or mode == "data":

                    d = line.split()
                    if len(d) != 0:
                        # If there is empty fields, they will be filled with NULL
                        if len(d) < len(labels):
                            for i in range(len(labels)-len(d)):
                                d.append("NULL")
                        data.append(d)
                        mode = "data"
        # Check if reched end of file after a chunk of data
        if mode == "data":
            self.makeTable(full_filename, name, labels, tuple(data))


