#!/bin/bash
# Usage
# ./gaincorrect.sh <"datafolder/linux wildcards"> <gain_reference.dm4> <defects.txt>
# note that the first argument must be included in ""
# gain reference and defects files must be in the same folder as images
# Uses clip, dm2mrc, and mrc2tif commands from imod package
# Uses GNU Parallel

JobList=$1
JobPath=${JobList%/*}
ImageList=${JobList##*/}
export GainRef=$2
export Defects=$3

echo "Folder containing files: $JobPath"
echo "Tiff images to be processed: $ImageList"
echo "Gain reference file: $GainRef"
echo "Detector Defects file: $Defects"

returnhere=$(pwd)

cd $JobPath
dm2mrc $GainRef gainref.mrc #convert gain reference file to mrc
echo "Starting parallel jobs..."
ls $ImageList | parallel -j+0 'clip mult -n 16 -m 2 -D $Defects {} gainref.mrc {.}_tmpgrc.mrc &&  mrc2tif -s -c lzw {.}_tmpgrc.mrc {.}_grc.tif && rm {.}_tmpgrc.mrc && echo "done {}"'
rm -rf *_tmpgrc.mrc

cd $returnhere
