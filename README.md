# EM Toolbox
Various tools to ease processing and conversion of particle files among various CryoEM software

## ImageOps (Python)
A couple of scripts for working with tif movies

usage: python tiftools.py -c <configfile>
see tiftools.conf for all available settings and definitions
 
    cropframes : select a range of frames with defined spacing
    removebar : circumvent detector malfunction resulting in black bar in tif movies. overwrite it with randomized data from elsewhere in image

## alignSum (MATLAB)
   align and ctf operations for SA grids
