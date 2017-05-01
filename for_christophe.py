from math import log
import sys

def ModExp (Base, Exp, Mod): 
  Hash = 1 
  X = Exp 
  Factor = Base 
  while X > 0 :
    Remainder = X % 2 
    X = X / 2 
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
  return (p**(e+1)-1)/(p-1)

def sigma(e):
  if (len(e) == 1):
    return usum(e[0][0],e[0][1])
  else:
    return usum(e[0][0],e[0][1])*sigma(e[1:])

FN = sys.argv[1]

A=open(FN)
C=open(FN+".cc","w")
line=1
H=A.readline().split(' ')
if (len(H)>1):
 line=int(H[1])
u=int(H[0])

smallp = []
for v in A:
 pp = int(v)
 if (IsPrime(pp)):
  smallp = smallp + [int(v)]
 else:
  print "AARGH composite ",pp
  die
smallp.sort()
while (2 != 3):
 f = []
 uu=u
 for p in smallp:
  if (u%p==0):
   ex=0
   while (u%p==0):
    ex=1+ex
    u=u/p
   f=f+[[p,ex]]
 if (IsPrime(u)):
  f=f+[[u,1]]
  u=1
 if (u==1):
  uf=""
  for v in f:
   if (v[1]==1):
    uf = uf + str(v[0]) + " * "
   else:
    uf = uf + str(v[0]) + "^" + str(v[1]) + " * "
  uf = uf[:-3]
  C.write("%04d"%line + " : ")
  C.write(str(uu)+" = "+uf+"\n")
#  print line,uu,log(uu)/log(10),f
  line=1+line
  u=sigma(f)-uu
 else:
  break
