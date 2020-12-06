# syntax: ecm-toy {size of number} {curves already done} {machine}
# eg ecm-toy G174 1000@11 tractor

import sys
import re
from math import exp,log

ecm_success_factor = {}
ecm_success_exponent = {}
ecm_timing = {}
gnfs_timing = {}

def fitlin(data):
    (s,sx,sy,sxx,sxy,syy) = (0,0,0,0,0,0)
    for x in data.keys():
        y = data[x]
        s = 1+s
        sx = x + sx
        sy = y + sy
        sxx = x*x + sxx
        sxy = x*y + sxy
        syy = y*y + syy

#    print(s, sx, sy, sxx, sxy, syy)

    ssxx = sxx - sx*sx/s;
    ssyy = syy - sy*sy/s;
    ssxy = sxy - sx*sy/s;
    m = ssxy/ssxx;
    c = (sy-m*sx)/s;
    return (m,c)

def fitexp(data):
    dl = {}
    for k in data.keys():
        dl[k]=log(data[k])
    (m,c)=fitlin(dl)
    return(exp(c),m)

def interpolate(hashy, value):
    K = hashy.keys()
    kk = [-9999,9999]
    for k in K:
        if (k<value and k>=kk[0]):
            kk[0]=k
        if (k>=value and k<=kk[1]):
            kk[1]=k
    delta = kk[1]-kk[0]
    try:
        y = [hashy[k] for k in kk]
        return y[0] + ((value-kk[0])/delta)*(y[1]-y[0])
    except:
        (M,e)=fitexp(hashy)
        return M*exp(e*value)

def load_datafiles(machine_name):
    global ecm_success_factor
    global ecm_success_exponent
    global ecm_timing
    global gnfs_timing

    n=0
    with open("ecm-probabilities.txt") as ep:
        for l in ep.readlines():
            d = [dd.rstrip("\n") for dd in l.split("\t")]
            if (len(d)==3):
                ecm_success_factor[int(d[0])] = float(d[1])
                ecm_success_exponent[int(d[0])] = float(d[2])
    with open("ecm-timings.txt") as et:
        for l in et.readlines():
            d = [dd.rstrip("\n") for dd in l.split("\t")]
            if (d[0] == machine_name):
                (e1,e2,e3)=(int(d[1]),float(d[2]),float(d[3]))
                if (e1 not in ecm_timing.keys()):
                    ecm_timing[e1]={}
                ecm_timing[e1][e2]=e3
    with open("gnfs-timings.txt") as gt:
        for l in gt.readlines():
            d = [dd.rstrip("\n") for dd in l.split("\t")]
            if (d[0] == machine_name):
                gnfs_timing[int(d[1])]=float(d[2])

snfs = False if sys.argv[1][0]=="G" else True
targdig = float(sys.argv[1][1:])

prior_work=sys.argv[2].split(",")
done = []
for p in prior_work:
    re_result = re.match(r'([0-9]*)@([0-9]*)',p)
    if re_result:
        (n_done,sz_done)=re_result.group(1,2)
        n_done = int(n_done)
        sz_done = int(sz_done)
        done = done + [[n_done,sz_done]]

print(done)

machine = "tractor"
if (len(sys.argv)==4):
    machine = sys.argv[3]

load_datafiles(machine)

# note that the exponential fit sometimes gives p>1 for
# digit counts small enough that success is certain
def success_prob(digits, B1):
    global ecm_success_factor
    global ecm_success_exponent
    p = ecm_success_factor[B1] * exp(digits*ecm_success_exponent[B1])
    return p if p<1 else 1

def update(prior, size, count):
    posterior = {}

    for k in prior.keys():
        sp = success_prob(k, size)
        posterior[k] = prior[k] * (1-sp)**count

    pp0 = sum([posterior[k] for k in posterior.keys()])
    for k in posterior.keys():
        posterior[k] = posterior[k] / pp0
    
    return posterior

if (snfs):
    # and for SNFS using a fit I did earlier
    nfs_time = 3600 * 7.72e-4 * exp(targdig*6.85e-2)
else:
    # estimate runtime for GNFS using interpolation
    nfs_time = 3600 * interpolate(gnfs_timing, targdig)


print("Expected NFS time is ",nfs_time/86400," days")

# set up prior probability
prior = {}
p0 = 0
for i in range(30,int(targdig/2)):
    #prior[i]=0.0 + 1.0*(log(i+1)/log(i))
    prior[i]=(i+0.0)**(-2.0)
    p0 = p0 + prior[i]
for j in range(30,int(targdig/2)):
    prior[j]=prior[j]/p0

print(prior)

# apply initial curves
for v in done:
    prior = update(prior, v[1], v[0])

posterior = prior

recipe = {}

for porpentine in range(20000):
    # try applying alternative curves
    # print posterior
    best_B1 = None
    best_t = nfs_time
    better_than_nfs = False
    for B1 in ecm_timing.keys():
        t_one_curve = interpolate(ecm_timing[B1], targdig)
        print("t_one_curve = ",t_one_curve)
        success_one_curve = [ [k,success_prob(k,B1)*posterior[k]] for k in posterior.keys()]
        tot_success_one_curve = sum([v[1] for v in success_one_curve])
        scaled_time = t_one_curve / tot_success_one_curve
        print("B1= ",B1," would have p=",tot_success_one_curve," eta=",scaled_time/86400," days")
        if (scaled_time < best_t):
            better_than_nfs = True
            (best_B1,best_t) = (B1,scaled_time)
    if (better_than_nfs):
        print("Best b1 is ",best_B1,"expected time",best_t/86400," days")
        # apply the best B1
        posterior = update(posterior, best_B1, 100)
        if (best_B1 in recipe.keys()):
            recipe[best_B1] = recipe[best_B1]+100
        else:
            recipe[best_B1] = 100
    else:
        print("And now NFS beats them")
        break

R = recipe.keys()
Rs=sorted(R)

print([[r,recipe[r]] for r in Rs])

q=[0 for s in range(1+int((targdig/2-30)/5))]
for k in posterior.keys():
    r=int((k-30)/5)
    q[r] = q[r] + posterior[k]

accum = 0
for g in range(len(q)):
    accum = accum + q[g]
    print("%2d..%2d %.4f %.4f" % (5*g+30,5*g+34,q[g],accum))
