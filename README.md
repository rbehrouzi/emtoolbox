# EM Toolbox


## gainrefcorrect
Bash script to apply gain reference and correct detector defects produced by SerialEM. Results are saved as LZW compressed tif files. The script uses modules from imod package and GNU Parallel.
Note: Currently, an alpha version of imod is needed to use this script.

GNU parallel: https://www.gnu.org/software/parallel/ (O. Tange (2018): GNU Parallel 2018, March 2018, https://doi.org/10.5281/zenodo.1146014)

IMOD: http://bio3d.colorado.edu/imod/

## getParticleSubset
Python script; extract a subset of particles from databases or star file, merging information across two sources.
Inputs: 
1. database/star file containing all particle positions
2. star/csv file containing selected particles without particle positions

Output:
star file containing selected particles with particle positions
