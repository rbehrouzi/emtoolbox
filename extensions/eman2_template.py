#!/usr/bin/env python
# The first line is critical, and must be exactly this

# Example Author block:
# Author: Steven Ludtke (sludtke@bcm.edu), 10/27/2010 - rewritten almost from scratch
# Author: David Woolford (woolford@bcm.edu), 9/7/2007 (woolford@bcm.edu)
# Copyright (c) 2000-2010 Baylor College of Medicine

# Official copyright notice. EMAN2 is distributed under a joint GPL/BSD license. 
# Please copy the actual notice from the top of one of the other EMAN2 programs. 
#
# You must agree to use this license if your
# code is distributed with EMAN2. While you may use your own institution for the copyright notice
# the terms of the GPL/BSD license permit us to redistribute it.

# all info: http://blake.bcm.edu/emanwiki/EMAN2/Library
# See standard params http://blake.bcm.edu/emanwiki/StandardParms
# Quick start guide http://blake.bcm.edu/emanwiki/Eman2ProgQuickstart


# import block, any necessary import statements
from EMAN2 import *
import math

# main() block. Each program will have a single function called main() which is executed when the
# program is used from the command-line. Programs must also be 'import'able themselves, so you
# must have main()
def main():

  progname = os.path.basename(sys.argv[0])
  usage = """prog [options]

  This is the main documentation string for the program, which should define what it does an how to use it.
  """  

  # You MUST use EMArgumentParser to parse command-line options
  parser = EMArgumentParser(usage=usage,version=EMANVERSION)
        
  parser.add_argument("--input", type=str, help="The name of the input particle stack", default=None)
  parser.add_argument("--output", type=str, help="The name of the output particle stack", default=None)
  parser.add_argument("--oneclass", type=int, help="Create only a single class-average. Specify the number.",default=None)
  parser.add_argument("--verbose", "-v", dest="verbose", action="store", metavar="n",type=int, default=0, help='verbose level [0-9], higher number means higher level of verboseness')

  (options, args) = parser.parse_args()

  # Now we have a call to the function which actually implements the functionality of the program
  # main() is really just for parsing command-line arguments, etc.  The actual program algorithms 
  # must be implemented in additional functions so this program could be imported as a module and
  # the functionality used in another context

  E2n=E2init(sys.argv)

  data=EMData.read_images(options.input)

  results=myfunction(data,options.oneclass)

  for im in results: im.write_image(options.output,-1)

  E2end(E2n)

def myfunction(data,oneclass):
  # do some stuff
  ret = [i*5.0 for i in data]

  return ret

# This block must always be the last thing in the program and calls main()
# if the program is executed, but not if it's imported
if __name__ == "__main__":
    main()