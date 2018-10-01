
import pandas as pd
import sqlite3
import os

#masterDb = input("Path to SQL databse ["+masterDb+"] "); 


def cistemRmFile(masterDb):
    ## use this script to remove files corresponding to items in a specific database table
    ## the intended use is to remove micrograph files or symlinks corresponding to bad items in cisTEM
    ## To use, create a table containing all low quality micrographs in CisTEM
    ## then point this script to the folder containing all micrographs (or symlinks)    masterDb="/data/reza/cisTEM/din-20bp/din-20bp.db"
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

def write_star(starfile, star, reindex=False):
    dict_merge2rln={'X_POSITION':'rlnCoordinateX', 'Y_POSITION':'rlnCoordinateY',
                     'FILENAME':'rlnImageName', 'NAME':'rlnMicrographName',
                     'ctf_params.df1':'rlnDefocusU','ctf_params.df2':'rlnDefocusV',
                     'ctf_params.angast_deg':'rlnDefocusAngle', 'ctf_params.akv':'rlnVoltage',
                     'ctf_params.cs':'rlnSphericalAberration', 'ctf_params.wgh':'rlnAmplitudeContrast'}

    if not starfile.endswith(".star"):
        starfile += ".star"
    with open(starfile, 'w') as f:
        f.write('\n')
        f.write("data_images" + '\n')
        f.write('\n')
        f.write("loop_" + '\n')
        for i in range(len(star.columns)):
            line = dict_merge2rln[star.columns[i]] + " \n"
            line = line if line.startswith('_') else '_' + line
            f.write(line)
    star.to_csv(starfile, mode='a', sep=' ', header=False, index=False)

def cistemGetSubset(masterDb, selectList):
    #Python script; extract a subset of particles from databases or star file, merging information across two sources. 
    # Inputs:
    #   1. database/star file containing all particle positions
    #   2. star/csv file containing selected particles without particle positions
    # Output: 
    #   star file containing selected particles with particle positions


    #masterDb="sir3_din.db"
    #selectList="selected.star"

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

    #ctf_params.akv,ctf_params.angast_deg,ctf_params.angast_rad,ctf_params.cs,ctf_params.detector_psize,
    # ctf_params.df1,ctf_params.df2,ctf_params.mag,ctf_params.phase_shift,ctf_params.psize,
    # ctf_params.wgh,data_input_relpath,data_input_idx,alignments.model-best.phiC

    #retrieve the master list of all particles from cisTEM database and the file path 
    conn = sqlite3.connect(masterDb)
    allparticles = pd.read_sql_query("""
    select cast(PARTICLE_POSITION_ASSET_ID as int) as ppid, 
    filename,name,
    x_position, 
    y_position
    from image_assets, particle_position_assets where 
    image_assets.image_asset_id = particle_position_assets.parent_image_asset_id;""", conn)
    conn.close()

    #TODO: process header lines of csparc csv
    selected = pd.read_csv("cryosparc_selected.csv",sep=',',dtype={'uid':int})
    merged=selected.merge(allparticles, left_on='uid',right_on='ppid')

    #Todo: hash csparc column names to relion _rln...
    columns_for_relion=['X_POSITION', 'Y_POSITION', 'FILENAME', 'NAME','ctf_params.df1','ctf_params.df2','ctf_params.angast_deg','ctf_params.akv',
                        'ctf_params.cs','ctf_params.wgh']
    write_star("output.star",merged[columns_for_relion])

    # add support for recasting path of image files
    # select only useful columns of csparc
    #_rlnCoordinateX #1 
    #_rlnCoordinateY #2 
    #_rlnClassNumber #3 
    #_rlnAnglePsi #4 
    #_rlnAutopickFigureOfMerit #5 
