#!/usr/bin/python3

from math import log,exp
import os
import sys
import shutil
from subprocess import Popen,PIPE
from tempfile import mkdtemp
from datetime import datetime,timedelta

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
PROG_GNFSDIR="/home/nfsworld/gnfs-batalov"


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

# one curve at 1e5 on a C70 is about 0.6 seconds
# one curve at 1e5 on a C84 is about 1.0 seconds

# msieve: 2-second barrier is about n=54

def GuessECMtime(N):
 return log(N)/(85*log(10)) 

def GuessMSIEVEtime(N):
 samples = [[56,4],[64,31],[66,44],[67,51],[68,90],[69,70],[70,81],[71,148],[72,175],[73,212],[80,1052],[84,1637]]
 n = log(N)/log(10)
 return exp(0.22*n-10.7)

def GuessGNFStime(N):
# curve-fit (to a large sample of measured polsel+sieve+linalg)
 n = log(N)/log(10)
 return exp(0.113*n-1.8)

def TrySomeECM(N):
 print("Trying ECM on %s for the %.1fth time" % (N,ECMdone[N]))
 if (ECMdone[N] < 10): lim=10000
 else: 
  if (ECMdone[N] < 100): lim=30000
  else: 
   if (ECMdone[N] < 1000): lim=100000
   else: 
    if (ECMdone[N] < 10000): lim=300000
    else:
     if (ECMdone[N] < 100000): lim=1000000
     else:
      lim=3000000
 ECMdone[N] = (lim/100000.0)+ECMdone[N]
 UpdateECMcache()
 process1 = Popen(["echo",str(N)], stdout=PIPE)
 cmdline = [PROG_ECM,"-q","-c","1",str(lim)]
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

def Factors(N):
 if (log(N)/log(10) < 18):
  return FactorsByFactor(N)
 if (log(N)/log(10) < 50):
  return FactorsByMsieve(N)
 else:
  print("C"+str(int(log(N)/log(10)+1)),N," is quite big")
  if (N not in ECMdone):
   ECMdone[N]=0

  ecmlimit_all = int(GuessGNFStime(10**nfslimit)/GuessECMtime(10**nfslimit))/2

  ecmlimit_m = int(GuessMSIEVEtime(N)/GuessECMtime(N))/2
  ecmlimit_n = int(GuessGNFStime(N)/GuessECMtime(N))/2
  ecmlimit = ecmlimit_m
  if (ecmlimit_n < ecmlimit_m):
   ecmlimit = ecmlimit_n
  if (ecmlimit > ecmlimit_all):
   ecmlimit=ecmlimit_all
  print("Trying up to",ecmlimit,"curves on",N)
  if (ECMdone[N] < ecmlimit):
   return TrySomeECM(N)
  else:
   if (log(N)/log(10) < 85):
    print("Factoring by msieve anyway ...")
    return FactorsByMsieve(N)
   else:
    print("GNFS probably faster")
    return FactorsByGNFS(N)

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

def FactorsByGNFS(N):
 dname = "gnfs."+str(N)
 ndig = log(N)/log(10)
 if (ndig > nfslimit):
  print(f"Command-line tells me not to run NFS on numbers above {nfslimit} digits")
  sys.exit(0)
 if (ndig < 87):
  fblim=300000
  lp=22
  siever="11"
 if (ndig > 87 and ndig < 89):
   fblim=300000
   lp=23
   siever="11"
 if (ndig > 89 and ndig < 91):
  fblim=500000
  lp=23
  siever="11"
 if (ndig > 91 and ndig < 95):
  fblim = 500000 # exp(0.053*ndig+9)
  lp = 24
  siever = "12"
 if (ndig > 95 and ndig < 105):
  lp = 24
  fblim = 1000000
  siever = "12"
 if (ndig > 105 and ndig < 115):
  lp = 25
  fblim = 2000000
  siever = "12"
 if (ndig > 115 and ndig < 125):
  lp = 26
  fblim = 4000000+(ndig-115)*200000
  siever = "13"
 if (ndig > 125 and ndig < 135):
  lp = 27
  fblim = 10000000
  siever = "13"
 if (ndig > 135 and ndig < 140):
  lp = 28
  fblim = 10000000
  siever = "14"
 if (ndig > 140 and ndig < 145):
  lp = 28
  siever = "14"
  fblim = 15000000
 if (ndig > 145):
  print("Not prepared to pick parameters automatically at this level")
  sys.exit(7)

 if (not os.path.exists(dname)):
  os.mkdir(dname);
 if (not os.path.exists(dname+"/msieve.fb")):
  print("Running polynomial selection for ",N)
  D=open(dname+"/worktodo.ini","w")
  D.write(str(N)+"\n")
  D.close()
  cmdline = [PROG_MSIEVE,"-v","-np"];
  aus = Popen(cmdline,cwd=dname,stdout=PIPE).communicate()[0].decode("utf-8").split('\n')
 if (not os.path.exists(dname+"/gnfs")):
  lines = {}
  C=open(dname+"/msieve.fb")
  degree=4
  for line in C:
   s=line.split()
   lines[s[0]]=s[1]
   if(s[0][0]=="A" and int(s[0][1])>degree):
    degree=int(s[0][1])
  D=open(dname+"/gnfs","w")
  D.write("n: "+lines["N"]+"\n")
  D.write("skew: "+lines["SKEW"]+"\n")
  D.write("Y0: "+lines["R0"]+"\n")
  D.write("Y1: "+lines["R1"]+"\n")
  for u in range(degree+1):
   su=str(u)
   D.write("c"+su+": "+lines["A"+su]+"\n")
  D.write("alim: "+str(fblim)+"\n")
  D.write("rlim: "+str(fblim)+"\n")
  D.write("lpba: "+str(lp)+"\n")
  D.write("lpbr: "+str(lp)+"\n")
  D.write("mfba: "+str(2*lp)+"\n")
  D.write("mfbr: "+str(2*lp)+"\n")
  D.write("alambda: 2.6\nrlambda: 2.6\n")
  D.close()

 Q0 = fblim
 target_yield = -1
 if (lp == 22):
  target_yield = 500000
 if (lp == 23):
  target_yield = 1000000
 if (lp == 24):
  target_yield = 2000000+(ndig-95)*100000
 if (lp == 25):
  target_yield = 3600000+(ndig-105)*100000
 if (lp == 26):
  target_yield = 6500000
 # experimentally, putting 14M gives sieves that give around 15M, so put 12M here
 if (lp == 27):
  target_yield = 12500000
 if (lp == 28):
  target_yield = 22000000
 if (target_yield == -1):
  print("lp ",lp," not suitable")
  sys.exit(8)
 print("Initial yield estimate")
 # sample more widely when the run will take longer
 # tendency otherwise to get embarrassingly high or low
 iye_range = 1000
 if (lp > 24):
  iye_range = 10000
 if (not os.path.exists(dname+"/e1")):
  print("Sampling a little around Q =",Q0)
  cmdline = [PROG_GNFSDIR+"/gnfs-lasieve4I"+siever+"e","-o","e0","-a","gnfs","-f",str(Q0),"-c",str(iye_range)]
  aus = Popen(cmdline,cwd=dname,stdout=PIPE,stderr=PIPE).communicate()[1].decode("utf-8").split("\r")
  D=open(dname+"/e1","w")
  print(aus)
  D.write(aus[-1])
  D.close()
 E=open(dname+"/e1")
 line=E.readline()
 terms=line.split()
 ypq=int(terms[2][:-1])/float(iye_range)
 tpr=float(terms[4][1:])
 print(ypq,tpr,target_yield/ypq, target_yield*tpr)

 if (os.path.exists(dname+"/tosieve")):
  # get the parameters from tosieve
  E = open(dname+"/tosieve")
  u=E.readline().split()
  rname = u[0]
  q0 = int(u[1])
  nq = int(u[2])-int(u[1])
 else:
  nq = target_yield/ypq
  if (nq > Q0):
   q0 = Q0//2
  else:
   q0 = Q0 - nq//2
  q0 = 10000*int(q0/10000)
  nq = 10000*int((nq/10000)+1)
  E = open(dname+"/segments","w")
  E.write(str(q0)+" "+str(q0+nq)+"\n")
  E.close()
  E = open(dname+"/tosieve","w")
  rname="rels"
  E.write(rname+" "+str(q0)+" "+str(q0+nq)+"\n")
  E.close()

 scmdline = [PROG_GNFSDIR+"/gnfs-lasieve4I"+siever+"e","-o",rname,"-a","gnfs","-f",str(q0),"-c",str(nq)]
 eta_seconds = nq*ypq*tpr
 if (os.path.exists(dname+"/"+rname)):
  scmdline = scmdline + ["-R"]
  complete = (lastQ(dname+"/"+rname)-q0)/(nq+0.0)
  print("Resuming job, about ",'%4.1f'%(complete*100),"% complete")
  eta_seconds = eta_seconds * (1-complete)
 print("Time is ",datetime.now().strftime("%d %B %Y %H:%M:%S"))
 etas = (datetime.now()+timedelta(eta_seconds/86400)).strftime("%d %B %Y %H:%M:%S")
 print("Sieving",nq,"Q starting at",q0," ETA is ",etas)
 aus = Popen(scmdline,cwd=dname,stdout=PIPE,stderr=PIPE).communicate()[1]
 os.remove(dname+"/tosieve")
 E = open(dname+"/w"+rname,"a")
 E.write(aus.decode("utf-8"))
 E.close()

 print("Sieving completed; building msieve.dat")
 # make msieve.dat out of rels
 A = open(dname+"/msieve.dat","w")
 A.write("N "+str(N)+"\n")
 sn = "rels"
 while (os.path.exists(dname+"/"+sn)):
  print("merging in",sn)
  B = open(dname+"/"+sn)
  for line in B:
   A.write(line)
  B.close()
  sn = sn+"."
 A.close()
 print("msieve.dat built; calling msieve")
 cmdline = [PROG_MSIEVE,"-v","-nc"];
 if (not(os.path.exists(dname+"/worktodo.ini"))):
  D=open(dname+"/worktodo.ini","w")
  D.write(str(N)+"\n")
  D.close()
 ausx = Popen(cmdline,cwd=dname,stdout=PIPE).communicate()[0].decode("utf-8").split("\n")
 print(ausx)

 # and finally list the factors
 fs = []
 for line in ausx:
  K = line.find("factor: ")
  if (K != -1):
   F = int(line[K+8:])
   fs += [F]
 if (fs != []):
  return fs

 # Umm.  If we get here, there weren't enough factors
 print("msieve didn't finish; not enough relations")
 E = open(dname+"/segments")
 qq = [int(t) for t in E.readline().split()]
 E.close()
 oldq0 = qq[0]; oldq1 = qq[1]
 oldlen = oldq1 - oldq0
 newlen = 10000*int((oldlen/100000)+1) # 0.1N rounded up
 if (oldq0 > Q0/2 and (len(rname)%2==1)):
  newq0 = qq[0]-newlen
  newq1 = qq[0]
  newH0 = newq0
  newH1 = oldq1
 else:
  newq0 = oldq1
  newq1 = oldq1+newlen
  newH0 = oldq0
  newH1 = newq1
 rname = rname+"."
 E = open(dname+"/segments","w")
 E.write(str(newH0)+" "+str(newH1))
 E.close()
 E = open(dname+"/tosieve","w")
 E.write(rname+" "+str(newq0)+" "+str(newq1))
 E.close()
 return FactorsByGNFS(N)
 exit(6)


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
  F = Factors(u)
  smallp = smallp + F
  CacheFactors(F,PROJNAME)
  u=uu

