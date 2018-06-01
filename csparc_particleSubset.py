# use this code to select a subset of particles for full-resolution 2D classification
#
# extracts a subset of particles indicated in a csparc csv file from the original star file exported from cistem

import pandas as pd

#_table,images
#_header
#uid,ctf_params.akv,ctf_params.angast_deg,ctf_params.angast_rad,ctf_params.cs,ctf_params.detector_psize,ctf_params.df1,ctf_params.df2,ctf_params.mag,ctf_params.phase_shift,ctf_params.psize,ctf_params.wgh,data_input_relpath,data_input_idx,alignments.model-best.phiC
#_dtypes
#int,float,float,float,float,float,float,float,float,float,float,float,string,int,float

#TODO: handle cryosparc csv headers and data types and write them back

original_csv="cryosparc_original.csv"
selected_csv="cryosparc_for_reex.csv"
newpath='20180525_sir3sir4ccdin_cistem.mrcs'
original_df = pd.read_csv("cryosparc_original.csv",sep=',',dtype={'uid':int})
selected_df = pd.read_csv("cryosparc_for_reex.csv",sep=',',dtype={'uid':int})
#selected_df.loc['data_input_relpath']=newpath
columns_to_keep=selected_df.columns
merged_df=original_df.loc[selected_df.uid,selected_df.columns]
merged_df.to_csv('cryosparc_selected.csv',index=False)