#!/bin/bash
# Usage
# ./gainrefcorrect.sh <"datafolder/wildcards"> <gain_reference.mrc> <defects.txt>
# Uses clip, dm2mrc, and mrc2tif commands from imod package
# Uses GNU Parallel, see reference in the readme file 
#
# Example gainrefcorrect.sh "./Apr14/set1-*.tif" Gatangainref.dm4 defectsfile.txt
# note that path is not required for gain referene and defects file. They are assumed to be in the same folder. 

JobList=$1
JobPath=${JobList%/*}
ImageList=${JobList##*/}
export GainRef=$2
export Defects=$3

grcconv()
{ 
  # $1: full file name $2: filename without extension
  clip mult -n 16 -m 2 -D $Defects $1 gainref.mrc $2_tmpgrc.mrc &&  
  mrc2tif -s -c lzw $2_tmpgrc.mrc $2_grc.tif 
  rm $2_tmpgrc.mrc
  echo "done with $1"
  return
}
echo "Folder containing files: $JobPath"
echo "Tiff images to be processed: $ImageList"
echo "Gain reference file: $GainRef"
echo "Detector Defects file: $Defects"
export -f grcconv 

returnhere=$(pwd)
cd $JobPath
dm2mrc $GainRef gainref.mrc #convert gain reference file to mrc
ls $ImageList | parallel --eta -j 4 'grcconv {} {.}'
cd $returnhere
