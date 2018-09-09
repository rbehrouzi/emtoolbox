
import tifffile as tif
import numpy as np
import glob
import ntpath
import multiprocessing as mp

inPath='d:/'
fixedpath=""
badBox=(0,7419,1023,2045) # y/height start-end, x/width start-end
goodBox=(0,7419,0,1022)
cores=mp.cpu_count()

def fixtiff(badtifffile):
	print("fixing "+ badtifffile)

	with tif.TiffFile(badtifffile) as im:
		imdata = im.asarray() #tif data as numpy array
		goodData=np.reshape(imdata[:,goodBox[0]:goodBox[1],goodBox[2]:goodBox[3]],-1)
		np.random.shuffle(goodData)
		imdata[:,badBox[0]:badBox[1],badBox[2]:badBox[3]]=np.reshape(goodData,(imdata.shape[0],badBox[1]-badBox[0],-1))

	file_head, file_tail = ntpath.split(badtifffile)
	file_basename, file_ext=ntpath.splitext(file_tail)
	fixedfile = f"{file_head}/{fixedpath}{file_basename}_fix{file_ext}"
	tif.imsave(fixedfile,imdata,bigtiff=True,compress=5)
	print("saved "+ f"{file_basename}_fix{file_ext}.")
	return 

if __name__ == '__main__':

	pool = mp.Pool(processes=cores)
	jobs = []

	#create a job list, overhead is only the name of the tif files
	for badTiff in glob.glob(f"{inPath}*.tif"):
		jobs.append(pool.apply_async(fixtiff,(badTiff,)))

	#run jobs
	for job in jobs:
		job.get()

	pool.close()
