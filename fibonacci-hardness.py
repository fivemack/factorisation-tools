#!/usr/bin/python3

import re
from math import log,sqrt

logs5=log(sqrt(5))/log(10)
logphi=log((1+sqrt(5))/2)/log(10)

adj=[[21,6,12./21],[15,4,8./15],[7,6,6./7],[5,4,4./5],[11,5,10./11],[3,6,2./3]]

ladj=[[21,6,12./21],[15,4,8./15],[14,6,6./7],[10,4,4./5],[6,4,2./3],[11,5,10./11],[3,6,2./3]]

auradj=[[3,4,2./3]]

hmax=360

f=open("fibonacci.txt")
for line in f:
    r = re.match(r'F([0-9]+)\W.*C([0-9]+)',line)
    if (r):
        n=int(r.group(1))
        gsz=int(r.group(2))
        ssz=logphi*n-logs5
        sdeg=6
# SNFS difficulty adjustments for different factors
        for p in adj:
            if (n%p[0]==0):
                sdeg=p[1]
                ssz=ssz*p[2]
                break

        if (gsz<hmax):
            print(["F",n,gsz,sdeg,ssz,gsz/ssz])

f=open("lucas.txt")
for line in f:
    r = re.match(r'L([0-9]+[AB]?)\W.*C([0-9]+)',line)
    if (r):
        lucname=r.group(1)
        s = re.match(r'([0-9]+)([AB])',lucname)
        if (s):
            n=int(s.group(1))
            auri=1
            aurl=s.group(2)
        else:
            n=int(r.group(1))
            auri=0
            aurl=""
        gsz=int(r.group(2))
        ssz=logphi*n
        sdeg=6
# SNFS difficulty adjustments for different factors
        if (auri==0):
            for p in ladj:
                if (n%p[0]==0):
                    sdeg=p[1]
                    ssz=ssz*p[2]
                    break
        else:
            ssz=ssz*2./5
            sdeg=4
            for p in auradj:
                if (n%p[0]==0):
                    sdeg=p[1]
                    ssz=ssz*p[2]
                    break
        if (gsz<hmax):
            print(["L",str(n)+aurl,gsz,sdeg,ssz,gsz/ssz])
