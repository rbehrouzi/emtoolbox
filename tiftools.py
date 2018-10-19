
import tifffile as tif
import numpy as np
import glob
import ntpath
import multiprocessing as mp
import sys, getopt

def main():
	try:
		opts, args = getopt.getopt(sys.argv[1:],"c:h",["config="])
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

	settings = readconfiguration(configfile)
	print(f"Running {settings['tif_tool']} in {settings['run_mode']}")

	if settings['run_mode']=='parallel':
		parallelize(settings)
	else:
		serialize(settings)

def readconfiguration(configfile):
	if not configfile:
		print("Config file not found.")
		exit(2)
	settings={}
	with open(configfile) as cfobj:
		for line in cfobj:
			if line[0]=='-':
				config, value=line[1:].split()
				settings[config]=value
			else:
				pass

	settings['tif_files']=glob.glob(f"{settings['search_path']}/*.tif")
	settings['max_load']=int(settings['max_load'])
	if settings['max_load']==0:
		settings['max_load']= min(mp.cpu_count(),len(settings['tif_files']))
	
	return settings

def serialize(settings):
	functionname=settings['tif_tool']
	tiffiles=settings['tif_files']
	for tifimage in tiffiles:
		eval(f"{functionname}('{tifimage}',settings)")

def parallelize(settings):
	functionname=settings['tif_tool']
	tiffiles=settings['tif_files']
	shares=mp.Manager() #for data available to all processes
	sharedsettings=shares.dict(settings)
	workers = mp.Pool(processes=settings['max_load'],initializer=None,initargs=None,maxtasksperchild=1) # create new workers for every file to free up any resources

	results = []
	for tifimage in tiffiles:
		results.append(workers.apply_async(func=eval(functionname),args=(tifimage,sharedsettings)))
	workers.close()
	workers.join()  # wait till everything is done
	if all (map(mp.pool.AsyncResult.successful, results)):
		print("all files processed successfully")
	else:
		print("some processes failed.")
	return

def cropframes(tifimage,settings):
	print(f"working on {tifimage}")
	framerange = range(int(settings['start_frame']), int(
		settings['end_frame']), int(settings['step_size']))
	fixedfile = f"{tifimage}.fix"
	with tif.TiffFile(tifimage) as im:
		imdata = im.asarray() #tif data as numpy array
		tif.imsave(fixedfile,imdata[framerange,:,:],bigtiff=True,compress=5)
	print("saved " + fixedfile)

def removebar(tifimage,settings):
	goodBox = [int(el.strip()) for el in settings['good_box'].split(',')]
	badBox =  [int(el.strip()) for el in settings['bad_box'].split(',')]
	print(f"working on {tifimage}")
	fixedfile = f"{tifimage}.fix"
	with tif.TiffFile(tifimage) as im:
		imdata = im.asarray() #tif data as numpy array
		goodData=np.reshape(imdata[:,goodBox[0]:goodBox[1],goodBox[2]:goodBox[3]],-1)
		np.random.shuffle(goodData)
		imdata[:,badBox[0]:badBox[1],badBox[2]:badBox[3]]=np.reshape(goodData,(imdata.shape[0],badBox[1]-badBox[0],-1))
	tif.imsave(fixedfile,imdata,bigtiff=True,compress=5)
	print(f"saved {fixedfile}")
	return 

if __name__ == '__main__':
	main()
