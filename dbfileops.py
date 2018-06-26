import pandas as pd
import sqlite3
import os

masterDb="din-20bp.db"
conn = sqlite3.connect(masterDb)
image_group_names = pd.read_sql_query("select * from image_group_list",conn)
print(image_group_names)
group_id = input("\nWhat is the group ID? ")
selected_image_group = "image_group_"+group_id

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


