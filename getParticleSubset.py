#Python script; extract a subset of particles from databases or star file, merging information across two sources. 
# Inputs:
#   1. database/star file containing all particle positions
#   2. star/csv file containing selected particles without particle positions
# Output: 
#   star file containing selected particles with particle positions

import pandas as pd
import sqlite3

masterDb="sir3_din.db"
selectList="selected.star"

# TABLE PARTICLE_POSITION_ASSETS
# PARTICLE_POSITION_ASSET_ID INTEGER PRIMARY KEY, 
# PARENT_IMAGE_ASSET_ID INTEGER, 
# PICKING_ID INTEGER, 
# PICK_JOB_ID INTEGER, 
# X_POSITION REAL, 
# Y_POSITION REAL, 
# PEAK_HEIGHT REAL, 
# TEMPLATE_ASSET_ID INTEGER, 
# TEMPLATE_PSI REAL, 
# TEMPLATE_THETA REAL, 
# TEMPLATE_PHI REAL ;

#IMAGE_ASSETS
# IMAGE_ASSET_ID INTEGER PRIMARY KEY, 
# NAME TEXT, 
# FILENAME TEXT, 
# POSITION_IN_STACK INTEGER, 
# PARENT_MOVIE_ID INTEGER, 
# ALIGNMENT_ID INTEGER, 
# CTF_ESTIMATION_ID INTEGER, 
# X_SIZE INTEGER, 
# Y_SIZE INTEGER, 
# PIXEL_SIZE REAL, 
# VOLTAGE REAL, 
# SPHERICAL_ABERRATION REAL, 
# PROTEIN_IS_WHITE INTEGER


def write_star(starfile, star, reindex=False):
    if not starfile.endswith(".star"):
        starfile += ".star"
    with open(starfile, 'w') as f:
        f.write('\n')
        f.write("data_images" + '\n')
        f.write('\n')
        f.write("loop_" + '\n')
        for i in range(len(star.columns)):
            line = star.columns[i] + " \n"
            line = line if line.startswith('_') else '_' + line
            f.write(line)
    star.to_csv(starfile, mode='a', sep=' ', header=False, index=False)

#retrieve the master list of all particles from cisTEM database and the file path 
conn = sqlite3.connect(masterDb)
allparticles = pd.read_sql_query("""
   select PARTICLE_POSITION_ASSET_ID, 
   filename,
   x_position, 
   y_position 
   from image_assets, particle_position_assets where 
   image_assets.image_asset_id = particle_position_assets.parent_image_asset_id;""", conn)
conn.close()
print(allparticles.columns)

#skip empty lines, titles, and datatypes in csparc csv
selected = pd.read_csv("cryosparc_selected.csv",sep=',')
merged=selected.merge(allparticles,left_on='uid',right_on='PARTICLE_POSITION_ASSET_ID')
print(selected.columns)
#hash csparc column names to relion _rln...
write_star("output.star",merged)

# add support for recasting path of image files
# select only useful columns of csparc
