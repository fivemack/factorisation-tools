#!/usr/bin/python3

from math import log,exp
import os
import sys
import shutil
from subprocess import Popen,PIPE
from tempfile import mkdtemp
from datetime import datetime,timedelta

def human_readable(n):
# TODO negative inputs
  if (n<1000): return "%.1f"%n
  if (n<1000000): return "%.1fk"%(n/1000)
  if (n<1000000000): return "%.1fM"%(n/1e6)
  if (n<1000000000000): return "%.1fG"%(n/1e9)
  return "%.2e"%n

machine = os.uname()[1]
print(machine)
PROG_ECM="/home/nfsworld/B/bin-i7/bin/ecm"
if (machine == "pig" or machine == "tractor"):
  PROG_ECM="/home/nfsworld/B/bin-phenom/bin/ecm"
if (machine == "butternut" or machine == "oak"):
  PROG_ECM="/home/nfsworld/ecm71-gmp61/exe-HSW/ecm"
if (machine == "pumpkin"):
  PROG_ECM="/home/nfsworld/ecm71-gmp61/exe-IVB/bin/ecm"
PROG_MSIEVE="/home/nfsworld/msieve"

PROG_ECM="/home/nfsworld/modern-gpu-ecm/gmp-ecm/ecm"

if (machine == "oak"):
  PROG_MSIEVE="/home/nfsworld/msieve-svn-20190823-gmpfix/msieve-MP-V256-SKL"

limit = 200
nfslimit = 138

if (sys.argv[1] == "-l" or sys.argv[1]=="-fl"):
  if (sys.argv[1] == "-l"):
    limit = float(sys.argv[2])
  else:
    nfslimit = float(sys.argv[2])
  PROJNAME=sys.argv[3]
else:
  PROJNAME=sys.argv[1]

def lastQ(fn):
 A=open(fn,"rb")
 A.seek(-1000,os.SEEK_END)
 lines=A.readlines()[1:-2]
 ends=[int(u.decode("utf-8").split(",")[-1],16) for u in lines]
 ed={};edi={}
 for t in ends:
  if (t in ed):
   ed[t]=1+ed[t]
  else:
   ed[t]=1
 for (k, v) in ed.items():
  edi[v]=k
 return edi[max(edi.keys())]

def PopulateECMcache():
 if (os.path.exists(PROJNAME+".ecm.cache")):
  A=open(PROJNAME+".ecm.cache","r")
  for line in A:
   S=line.split(' ')
   ECMdone[int(S[0])]=float(S[1])

def UpdateECMcache():
 A=open(PROJNAME+".ecm.cache2","w")
 for k in ECMdone.keys():
  A.write(str(k)+" "+str(ECMdone[k])+"\n")
 A.close()
 shutil.copyfile(PROJNAME+".ecm.cache2",PROJNAME+".ecm.cache")

ECMdone = {}
PopulateECMcache()

ECM_distrib = {}
ECM_time_spent = {}

# one curve at 1e5 on a C70 is about 0.6 seconds
# one curve at 1e5 on a C84 is about 1.0 seconds

# msieve: 2-second barrier is about n=54

def GuessECMtime(N):
 # 5120 curves at 1e5 on an RTX4080S is 1.2 seconds
 return 1.2/5120

def GuessMSIEVEtime(N):
 samples = [[56,4],[64,31],[66,44],[67,51],[68,90],[69,70],[70,81],[71,148],[72,175],[73,212],[80,1052],[84,1637]]
 n = log(N)/log(10)
 return exp(0.22*n-10.7)

def GuessGNFStime(N):
 n = log(N)/log(10)

# curve-fit (to a large sample of measured polsel+sieve+linalg)
# using cado on oak with 104 threads
# there is a clear knee in the curve
# and it flattens off wierdly below about 94 digits
# return exp(0.113*n-1.8) / 28
# return exp(0.108*n-1.01)/28
 if (n<94):
   return 280
 if (n<130):
   return 0.0665 * exp(0.0867*n)
 return 0.0038 * exp(0.1088*n)

def TrySomeECM(N, protocol):
 lim = protocol[0]
 print("Trying ECM (%s) on %s" % (human_readable(lim), N))
 process1 = Popen(["echo",str(N)], stdout=PIPE)
 cmdline = [PROG_ECM,"-q","-gpu",str(lim),"0"]
 process2 = Popen(cmdline, stdin=process1.stdout, stdout=PIPE)
 output = process2.communicate()[0][:-1].decode("utf-8")
 if (output == str(N)):
  return []
 else:
  print("SUCCESS ",output)
  factors = output.split(' ')
  Z=[]
  for u in factors:
   if IsPrime(int(u)):
    Z=Z+[int(u)]
   else:
    Z=Z+Factors(int(u))
  return Z

# B1 (assuming B2=0), number of hits on p20 from 5120 curves, exponent of fit

ECMFits = [[1e5, 46, -0.438],
           [6e5, 163, -0.386],
           [32e5, 297, -0.341],
           [287e5, 692, -0.283],
           [1e8, 918, -0.259]]

ECMTimescale = 36.643/32e5 # GPU-seconds for 5120 curves, as a multiple of B1

def PrintDistrib(dd):
  mm=-1
  for u in range(len(dd)):
    print("%3d %.4f"%(u+1,dd[u]))
    if (dd[u]>mm):
      mm=dd[u]
      m=u+1
  print("mode %d"%m)

def PriorDistrib(N):
  j=log(N)/log(100) # maximum number of digits in a factor
  dd=[r**-0.4 for r in range(1,int(j+1))]
  s=sum(dd); dd=[d/s for d in dd]
  return dd

def SuccessVector(d0, line):
  p20 = line[1]/5120
  cc = [exp(line[2]*(1+n)) for n in range(len(d0))]
  scale = p20/cc[20]
  cc = [min(1,c * scale) for c in cc]
  return cc

def SuccessChance(d0, line):
  cc = SuccessVector(d0,line)
  pp = [(1-(1-cc[n])**5120)*d0[n] for n in range(len(d0))]
  return sum(pp)

def UpdateDistrib(d0, line):
  cc = SuccessVector(d0, line)
  PrintDistrib(cc)
  pp = [((1-cc[n])**5120)*d0[n] for n in range(len(d0))]
  s = sum(pp)
  pp = [p/s for p in pp]
  print("Posterior updated to")
  PrintDistrib(pp)
  print("from")
  PrintDistrib(d0)
  return pp

def Factors(N, xname="wibble"):
 if (log(N)/log(10) < 18):
  return FactorsByFactor(N)
 if (log(N)/log(10) < 50):
  return FactorsByMsieve(N)
 else:
  print("C"+str(int(log(N)/log(10)+1)),N," is quite big")
  if (N not in ECMdone):
   ECMdone[N]=0

  if (N not in ECM_distrib):
    print("starting with default prior")
    ECM_distrib[N] = PriorDistrib(N)
    ECM_time_spent[N] = 0

  T = GuessGNFStime(N)
  print("Just doing GNFS would take %s; spent %s so far"%(T,ECM_time_spent[N]))
  task = None
  for q in ECMFits:
    p_win = SuccessChance(ECM_distrib[N],q)
    t_est = ECM_time_spent[N]+ECMTimescale*q[0]
    xt = t_est/p_win
    print(t_est/p_win, " at ", q[0])
    if (xt<T):
      T=xt
      task=q

  if (task != None):
    print("Performing ECM with ",task)
    t = TrySomeECM(N, task)
    if (t == []):
      ECM_distrib[N] = UpdateDistrib(ECM_distrib[N], task)
      ECM_time_spent[N] += ECMTimescale*task[0]
      return Factors(N, xname)
    else:
      return t
  else:
   if (log(N)/log(10) < 85):
    print("Factoring by msieve anyway ...")
    return FactorsByMsieve(N)
   else:
    print("GNFS probably faster")
    return FactorsByGNFS(N,xname)

def FactorsByFactor(N):
 cmdline = ["factor",str(N)];
 u = Popen(cmdline,stdout=PIPE).communicate()[0].decode("utf-8")
 u = u[:-1].split(' ')
 return [int(v) for v in u[1:]]

def FactorsByMsieve(N):
 fs = []
 cmdline = [PROG_MSIEVE,"-v",str(N)];
 msieve_wd = mkdtemp()
 aus = Popen(cmdline,cwd=msieve_wd,stdout=PIPE).communicate()[0].decode("utf-8").split('\n')
 for line in aus:
  K = line.find("factor: ")
  if (K != -1):
   F = int(line[K+8:])
   fs += [F]
 shutil.rmtree(msieve_wd)
 return fs

def FactorsByGNFS(N, name):
 fn=open("oak-queue/"+name,"w")
 fn.write(N)
 exit(7)
  
def ModExp (Base, Exp, Mod): 
  Hash = 1 
  X = Exp 
  Factor = Base 
  while X > 0 :
    Remainder = X % 2 
    X = X // 2 
    if Remainder == 1: 
      Hash = Hash * Factor % Mod 
    Factor = Factor * Factor % Mod
  return Hash   

def IsPrime(r):
  if (r in [2,3,5,7,11,13,31]):
    return True
  if (ModExp(3,r,r)==3 and ModExp(5,r,r)==5):  
    return True
  return False

def product(l):
  if (len(l) == 1):
    return l[0];
  else:
    return l[0] * product(l[1:])

def usum(p,e):
# usum(p,1)=p+1
# usum(p,2)=p**2+p+1
  return (p**(e+1)-1)//(p-1)

def sigma(e):
  if (len(e) == 1):
    return usum(e[0][0],e[0][1])
  else:
    return usum(e[0][0],e[0][1])*sigma(e[1:])

def CacheFactors(factors, file):
 if (factors != []):
  v = open(file,'a')
  for u in factors:
   v.write(str(u)+"\n")
  v.close()

A=open(PROJNAME)
line=1
hat=A.readline()
H = hat.split(' ')
if (len(H)>1):
 line=int(H[1])
u=int(H[0])
smallp = []
for v in A:
 pp = int(v)
 if (IsPrime(pp)):
  smallp = smallp + [int(v)]
 else:
  print("AARGH composite ",pp)
  sys.exit(1)
smallp.sort()
while (log(u)<limit*log(10)):
 f = []
 uu=u
 for p in smallp:
  if (u%p==0):
   ex=0
   while (u%p==0):
    ex=1+ex
    u=u//p
   f=f+[[p,ex]]
 if (IsPrime(u)):
  print("P",u)
  f=f+[[u,1]]
  u=1
 if (u==1):
  print(line,uu,log(uu)/log(10),f)
  line=1+line
  u=sigma(f)-uu
 else:
  print("C"+str(int(log(u)/log(10)+1.0))+" cofactor ",u)
  F = Factors(u,xname=PROJNAME+"."+str(line))
  smallp = smallp + F
  CacheFactors(F,PROJNAME)
  u=uu

