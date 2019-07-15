import os
import re
import pandas as pd
import numpy as np
from pandas import Series, DataFrame
import time
import argparse 
import sys

# parser = argparse.ArgumentParser(description="combine your qualitycontrolbam file, please input your regexp to match your file")
# parser.add_argument('--regexp', '-r', required=True, help='regexp')
time_start=time.time()
MyDiction = {}
def combinefile(regexp):
	for dirpath, dirs, files in os.walk('.'):
		for name in files:
			if re.match(regexp,name):
				filename = os.path.join(dirpath, name)
				f = open(filename,'r')
				for line in f:
					mylist = line.strip().split('\t')
					if mylist[0] in MyDiction:
						MyDiction[mylist[0]].append(mylist[1])
					else:
					 	MyDiction[mylist[0]] = [mylist[1]]
	df1 = DataFrame(MyDiction)
	df1.to_excel('Q20Q30.final.xlsx')
	f.close()
combinefile('(.*)Q20Q30.final(.*)')
time_end=time.time()
print('totally cost of time',time_end-time_start)






