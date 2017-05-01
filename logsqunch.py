from glob import glob
from datetime import datetime
import re
from math import log

files=glob("logs/C*")
for u in files:
 a=open(u,'r')
 l=a.readlines()

 start=datetime.strptime(l[0][:-3],"%a %b %d %H:%M:%S %Y")
 end=datetime.strptime(l[-1][0:24],"%a %b %d %H:%M:%S %Y")
 runtime=end-start
 runtime_secs = runtime.days*86400+runtime.seconds

 m=re.search(r'C(...)\.([0-9]+)\.mlog',u)
 logN=int(m.group(1))+log(int(m.group(2)))/log(10)
 logN=logN-len(m.group(2))
 print logN,runtime_secs
