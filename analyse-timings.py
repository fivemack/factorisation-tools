from glob import glob
import re
import os.path
from math import log
from datetime import datetime
from datetime import timedelta

def unvex(td):
  return 86400*td.days+td.seconds

def T(n):
 d={}
 s="JanFebMarAprMayJunJulAugSepOctNovDec"
 for u in range(12):
  d[s[3*u:3*u+3]]=1+u

 M=re.match("(...) (...) +([0-9]+) (..:..:..) ([0-9]+)",n)
 if (M != None):
  return datetime(int(M.group(5)),
                 d[M.group(2)],
                 int(M.group(3)),
                 int(M.group(4)[0:2]),
                 int(M.group(4)[3:5]),
                 int(M.group(4)[6:8]))
 else:
  print "Couldn't match ",n
  return datetime(2010,1,1,0,0,0)


runs=glob('logs/*.mlog')

for r in runs:
 F=open(r)
 N=-1
 startdate=""
 epsdate=""
 endsievedate=""
 finishdate=""
 escore=-1

 for l in F:
  # if the line is first to begin 'factoring', grab N and the date
  if (N==-1 and l[26:35]=="factoring"):
   N=int(re.match("[0-9]*",l[36:]).group(0))
   startdate=l[0:25]
  # if the line is first to begin 'elapsed time', it's the end of the polsel
  if (epsdate=="" and l[26:38]=="elapsed time"):
   epsdate=l[0:25]
  # end-of-sieving is the *last* line matching Msieve
  if (l[26:32]=="Msieve"):
   endsievedate=l[0:25]
  if (l[26:29]=="prp"):
   finishdate=l[0:25]
  M = re.search("combined = ([0-9.e-]*)",l)
  if (M != None):
   escore=float(M.group(1))
  M = re.search("([0-9]+) duplicates and ([0-9]+) unique",l)
  if (M != None):
   nur = int(M.group(2))
   nxr = nur+int(M.group(1))
  M = re.search("matrix is ([0-9]+) x ([0-9]+)",l)
  if (M != None):
   msz = int(M.group(2))

 bigP=-1; littleP=-1;
 if (os.path.exists(r+"/gnfs")):
  G=open(r+"/gnfs")
  for l in G:
   if (l[0:4]=="lpba"):
    bigP=int(l[6:])
   if (l[0:4]=="alim"):
    littleP=int(float(l[6:]))
 
 if (finishdate != "" and bigP!=-1):
  std = T(startdate)
  epd = T(epsdate)
  esd = T(endsievedate)
  fid = T(finishdate)
  pstime=epd-std
  sievetime=esd-epd
  finishtime = fid-esd
  print log(N)/log(10), bigP, littleP, nrels, nxr, nur, unvex(pstime), unvex(sievetime), unvex(finishtime), escore, msz
