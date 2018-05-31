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
    dict_csparc2rln={'X_POSITION':'_rlnCoordinateX', 'Y_POSITION':'_rlnCoordinateY'}
    if not starfile.endswith(".star"):
        starfile += ".star"
    with open(starfile, 'w') as f:
        f.write('\n')
        f.write("data_images" + '\n')
        f.write('\n')
        f.write("loop_" + '\n')
        for i in range(len(star.columns)):
            line = dict_csparc2rln[star.columns[i]] + " \n"
            #line = line if line.startswith('_') else '_' + line
            f.write(line)
    star.to_csv(starfile, mode='a', sep=' ', header=False, index=False)

#retrieve the master list of all particles from cisTEM database and the file path 
conn = sqlite3.connect(masterDb)
allparticles = pd.read_sql_query("""
   select cast(PARTICLE_POSITION_ASSET_ID as int) as ppid, 
   filename,
   x_position, 
   y_position
   from image_assets, particle_position_assets where 
   image_assets.image_asset_id = particle_position_assets.parent_image_asset_id;""", conn)
conn.close()

#Todo: skip empty lines, titles, and datatypes in csparc csv
selected = pd.read_csv("cryosparc_selected.csv",sep=',',dtype={'uid':int})
merged=selected.merge(allparticles, left_on='uid',right_on='ppid')

#Todo: hash csparc column names to relion _rln...
write_star("output.star",merged[['X_POSITION', 'Y_POSITION']])

# add support for recasting path of image files
# select only useful columns of csparc
#_rlnCoordinateX #1 
#_rlnCoordinateY #2 
#_rlnClassNumber #3 
#_rlnAnglePsi #4 
#_rlnAutopickFigureOfMerit #5 
