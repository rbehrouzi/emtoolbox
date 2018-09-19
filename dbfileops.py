## use this script to remove files corresponding to items in a specific database table
## the intended use is to remove micrograph files or symlinks corresponding to bad items in cisTEM
## To use, create a table containing all low quality micrographs in CisTEM
## then point this script to the folder containing all micrographs (or symlinks)

import pandas as pd
import sqlite3
import os

masterDb="/data/reza/cisTEM/din-20bp/din-20bp.db"
#masterDb = input("Path to SQL databse ["+masterDb+"] "); 
print("working on "+masterDb)

conn = sqlite3.connect(masterDb)
image_group_names = pd.read_sql_query("select * from IMAGE_GROUP_LIST",conn)
print(image_group_names)
group_id = input("\nWhat is the group_ID? ")
selected_image_group = "IMAGE_GROUP_"+group_id

files_in_image_group = pd.read_sql_query("select filename from image_assets, " + selected_image_group + 
   " where image_assets.image_asset_id = " + selected_image_group + ".image_asset_id;", conn)
conn.close()

target_folder ="./"
target_folder = input("Where is the target folder containing copied files? [./] ")
for filename in files_in_image_group['FILENAME'].tolist():
    (fpath, fname) = os.path.split(filename)
    target_file=os.path.join(target_folder,fname)
    if os.path.isfile(target_file):
        os.remove(target_file)
    else:
        print("target file does not exist: "+target_file)

