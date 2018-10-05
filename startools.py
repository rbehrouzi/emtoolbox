
# all info: http://blake.bcm.edu/emanwiki/EMAN2/Library
# See standard params http://blake.bcm.edu/emanwiki/StandardParms
# Quick start guide http://blake.bcm.edu/emanwiki/Eman2ProgQuickstart

import pandas as pd
from EMAN2 import *
import os, ntpath,sys

   # make python3 input command backward compatible
try:
    input = raw_input
except NameError:
    pass

def main():
    # main() block. Each program will have a single function called main() which is executed when the
    # program is used from the command-line. Programs must also be 'import'able themselves, so you
    # must have main()

    progname = os.path.basename(sys.argv[0])
    usage = """prog [options]
    This is the main documentation string for the program, which should define what it does an how to use it.
    """  

    # You MUST use EMArgumentParser to parse command-line options
    #parser = EMArgumentParser(usage=usage,version=EMANVERSION)
            
    #parser.add_argument("--input", type=str, help="The name of the input particle stack", default=None)
    #parser.add_argument("--output", type=str, help="The name of the output particle stack", default=None)
    #parser.add_argument("--oneclass", type=int, help="Create only a single class-average. Specify the number.",default=None)
    #parser.add_argument("--verbose", "-v", dest="verbose", action="store", metavar="n",type=int, default=0, help='verbose level [0-9], higher number means higher level of verboseness')

    #(options, args) = parser.parse_args()

    # Now we have a call to the function which actually implements the functionality of the program
    # main() is really just for parsing command-line arguments, etc.  The actual program algorithms 
    # must be implemented in additional functions so this program could be imported as a module and
    # the functionality used in another context

    #E2n=E2init(sys.argv)

    #data=EMData.read_images(options.input)

    #results=myfunction(data,options.oneclass)
    #for im in results: im.write_image(options.output,-1)
    #E2end(E2n)

    starParticleStack()

def dfToStar(full_filename, data_table, conversion_dict={}):
# write pandas dataframe as start file
# if a conversion dictionary is provided, table column headers are converted accordingly
    if not full_filename.endswith(".star"):
        full_filename += ".star"
    with open(full_filename, 'w') as f:
        f.write('\n')
        f.write("data_" + '\n')
        f.write('\n')
        f.write("loop_" + '\n')
        for i in range(len(data_table.columns)):
            if conversion_dict: #empty dict is False
                line = conversion_dict[data_table.columns[i]] + " \n"
            else:
                line = data_table.columns[i] + "\n"
            line = line if line.startswith('_') else '_' + line
            f.write(line)

    data_table.to_csv(full_filename, mode='a', sep=' ', header=False, index=False)
    return

def starToDf (full_filename):
# read star file containing one data block into pandas dataframe
# returns dataframe
    headers = []
    lineskip_count=0
    reading_labels=False

    with open(full_filename) as f:
        # count header lines and store column headers
        for line in f:
            if line[0:4] == "_rln":
                reading_labels = True
                params = line.split()
                headers.append(params[0])
            else:
                # has the labels been read
                if reading_labels:
                    break
            lineskip_count += 1
        
        starDf= pd.read_table(full_filename, delimiter=' ', header=None, index_col=False,
                    skipinitialspace=True, skiprows=lineskip_count,
                    names=headers)
    return starDf

def readPltChain(list_file,check_parent):
# Reads SAMUEL (Maofu Liao) PLT files that contain selection numbers 
# It can iteratively navigate back through sub-selections if PLT files correspond to a parent PLT file
    read_lines=[]
    with open(list_file) as f:
        for line in f:
            read_lines.append(int(line)-1) #convert to zero-based index
    
    if check_parent:
        resp = input("\nIs "+list_file+" a subset of a previous selection file? [Y/N]")
        if resp.upper()=="Y":
            parent_list_file = input("\nWhat is the parent PLT file? ")
            ##TODO: check existence, etc.
            sub_selection = read_lines
            parent_lines=readPltChain(parent_list_file,check_parent)
            read_lines=[parent_lines[i] for i in sub_selection]
        else:
            check_parent=False
    return read_lines


def starSelectPlt():
# write a new star file from records selected from parent star file
# selection is defined in PLT file (SAMUEL)
    default_output="particles_selected.star"
    default_star = "particles.star"
    default_list = "child_list.plt"

    resp = input("\nWhat is the parent STAR file? ["+default_star+"]")
    star_file= default_star if not resp else resp
    resp = input("\nWhat is the selection PLT file? ["+default_list+"]")
    list_file= default_list if not resp else resp
    resp = input("\nName of outputfile? ["+default_output+"]")
    output_file = default_output if not resp else resp

    selected_rows=readPltChain(list_file,True) #check if this is a sublist
    alldata_df=starToDf(star_file)
    output_file= default_output if not resp else resp
    dfToStar(output_file, alldata_df.loc[selected_rows,:]) 

def starParticleStack():
# create a single particle stack mrcs from records in the star file and per micrograph mrcs stacks
# uses EMAN2 LSXFile to create fast LST file 
# uses EMAN2 e2proc2d to create the mrcs file from LST file
    default_star = "particles.star"
    default_mrcs_folder = "average/"
    default_output = "particles.mrcs"

    resp = input("\nWhat is the particle STAR file? ["+default_star+"]")
    star_file = default_star if not resp else resp
    resp = input("\nWhat is the folder containing mrcs files? ["+default_mrcs_folder+"]")
    mrcs_folder = default_mrcs_folder if not resp else resp
    resp = input("\nName of mrcs particle stack to write? ["+default_output+"]")
    output_mrcs = default_output if not resp else resp

    star_df = starToDf(star_file)
    mrcs_list = star_df["_rlnImageName"].apply(ntpath.basename)
    mrcs_list = mrcs_list.apply('/'.join)
    if not mrcs_list:
        e2lsx_obj = LSXFile(star_file+".lsx") #LSXFile object to write out selection
    #for stack_name in mrcs_list:

    e2lsx_obj.write(-1, idx_stack, mrcs_folder+stack_name)  # append


# This block must always be the last thing in the program and calls main()
# if the program is executed, but not if it's imported
if __name__ == "__main__":
    main()
