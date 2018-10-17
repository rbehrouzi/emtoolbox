
import tifffile as tif
import numpy as np
import glob
import ntpath
import multiprocessing as mp
import sys, getopt

def main():
	global settings
   try:
      opts, etc = getopt.getopt(sys.argv,"hc:",["config="])
   except getopt.GetoptError:
      print("tiftools.py -c <configfile>")
      sys.exit(2)
   for opt, arg in opts:
	   if opt == '-h':
         print("tiftools.py -c <configfile>")
         sys.exit()
		elif opt in ("-c", "--config"):
         configfile = arg
		else:
			pass
		
	tiffiles=settings['tif_files']
	functionname=settings['tool_name']
	if settings['run_mode']='parallel':
		parallelize(functionname, tiffiles)
	else:
		serialize(functionname, tiffiles)

def readconfiguration(configfile):
	
	searchPath=settings['search_path']
	tiffiles=glob.glob(f"{inPath}*.tif")
	


def cropframes(tifstack):

	framerange=range(40) #) to 39
#	file_head, file_tail = ntpath.split(tifstack)
#	file_basename, file_ext=ntpath.splitext(file_tail)
#	fixedfile = f"{file_head}/{file_basename}_fix{file_ext}"
	fixedfile = f"{tifstack}.fix"
	with tif.TiffFile(tifstack) as im:
		imdata = im.asarray() #tif data as numpy array
		tif.imsave(fixedfile,imdata[framerange,:,:],bigtiff=True,compress=5)
	
def serialize(functionname,tiffiles):
	for tifstack in tiffiles:
		functionname(tifstack)

def parallelize(functionname,tiffiles):
	cores=mp.cpu_count()
	pool = mp.Pool(processes=np.min([cores,len(tiffiles)]))
	jobs = []
	#create a job list, overhead is only the name of the tif files
	for tifstack in tiffiles:
		jobs.append(pool.apply_async(functionname,(tifstack,)))

	#run jobs
	for job in jobs:
		job.get()

	pool.close()

def fixtiff(tifstack):

	print("fixing "+ tifstack)
#	file_head, file_tail = ntpath.split(tifstack)
#	file_basename, file_ext=ntpath.splitext(file_tail)
#	fixedfile = f"{file_head}/{file_basename}{file_ext}"
	fixedfile = f"{tifstack}.fix"
	with tif.TiffFile(tifstack) as im:
		imdata = im.asarray() #tif data as numpy array
		goodData=np.reshape(imdata[:,goodBox[0]:goodBox[1],goodBox[2]:goodBox[3]],-1)
		np.random.shuffle(goodData)
		imdata[:,badBox[0]:badBox[1],badBox[2]:badBox[3]]=np.reshape(goodData,(imdata.shape[0],badBox[1]-badBox[0],-1))
	tif.imsave(fixedfile,imdata,bigtiff=True,compress=5)
	print("saved "+ fixedfile)
	return 

if __name__ == '__main__':
	main()