# EM Toolbox


## gainrefcorrect.sh
Bash script to apply gain reference and correct detector defects produced by SerialEM. Results are saved as LZW compressed tif files. The script uses modules from imod package and GNU Parallel.
Note: Currently, an alpha version of imod is needed to use this script.

GNU parallel: https://www.gnu.org/software/parallel/ (O. Tange (2018): GNU Parallel 2018, March 2018, https://doi.org/10.5281/zenodo.1146014)

IMOD: http://bio3d.colorado.edu/imod/

## Rescalepos
Rescale position of particles across different binnings
