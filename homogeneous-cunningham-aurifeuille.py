import re

def hp(x,y,rr):
  L=len(rr)
  if (L==0):
    return 1
  return sum([x**(L-i-1)*y**i*rr[i] for i in range(L)])

def auri8p3(exp):
  h=exp/6
  k=(h+1)/2
  X,Y,XX,YY=[8**k,3**k,8**h,3**h]
  A=hp(XX,YY,[1,3,1])
  B=hp(XX,YY,[1,1])
  return [A-X*Y*B/2,A+X*Y*B/2]

def auri9p8(exp):
  h=exp/2
  k=(h+1)/2
  A=9**h+8**h
  B=6**h*2**k
  return [A-B,A+B]

def auri9m5(exp):
  h=exp/5
  k=(h+1)/2
  X,Y,XX,YY=[9**k,5**k,9**h,5**h]
  A=hp(XX,YY,[1,3,1])
  B=hp(XX,YY,[1,1])
  return [A-X*Y*B/3,A+X*Y*B/3]

def auri10p9(exp):
  h=exp/10
  k=(h+1)/2
  X,Y,XX,YY=[10**k,9**k,10**h,9**h]
  A=hp(XX,YY,[1,5,7,5,1])
  B=hp(XX,YY,[1,2,2,1])
  return [A-3**h*X*B,A+3**h*X*B]
  
def auri10p3(exp):
  h=exp/30
  k=(h+1)/2
  X,Y,XX,YY=[10**k,3**k,10**h,3**h]
  A=hp(XX,YY,[1,15,38,45,43,45,38,15,1])
  B=hp(XX,YY,[1,5,8,8,8,8,5,1])
  return [A-X*Y*B,A+X*Y*B]

def gen_auri(u,v,exp,rat,p1,p2,f):
  h=exp/rat
  k=(h+1)/2
  X,Y,XX,YY=[u**k,v**k,u**h,v**h]
  A,B=[hp(XX,YY,p1),hp(XX,YY,p2)]
  print "h=",h
  print "k=",k
  print "X=",X
  print "Y=",Y
  print "XX=%s YY=%s" % (XX,YY)
  print "A=%s B=%s" % (A,B)
  print A-X*Y*B/f
  print A+X*Y*B/f
  return [A-X*Y*B/f,A+X*Y*B/f]

def auri3p2(exp):
  return gen_auri(3,2,exp,6,[1,3,1],[1,1],1)

def auri4p3(exp):
  return gen_auri(4,3,exp,3,[1,1],[],2)

def auri5p2(exp):
  return gen_auri(5,2,exp,10,[1,5,7,5,1],[1,2,2,1],1)

def auri5p3(exp):
  return gen_auri(5,3,exp,15,[1,8,13,8,1],[1,3,3,1],1)

def auri5m4(exp):
  return gen_auri(5,4,exp,5,[1,3,1],[1,1],2)

def auri6p5(exp):
  return gen_auri(6,5,exp,30,
                  [1,15,38,45,43,45,38,15,1],
                  [1,5,8,8,8,8,5,1],
                  1)

def auri7p2(exp):
  return gen_auri(7,2,exp,14,[1,7,3,-7,3,7,1],[1,2,-1,-1,2,1],1)

def auri7m3(exp):
  return gen_auri(7,3,exp,21,[1,10,13,7,13,10,1],[1,3,2,2,3,1],1)

def auri7p4(exp):
  return gen_auri(7,4,exp,7,[1,3,3,1],[1,1,1],2)

def auri7p5(exp):
  return gen_auri(7,5,exp,35,[1,18,48,11,-55,-11,47,-11,-55,11,48,18,1],[1,6,7,-5,-8,5,5,-8,-5,7,6,1],1)

def auri7p6(exp):
  return gen_auri(7,6,exp,42,
                  [1,21,74,105,55,-42,-91,-42,55,105,74,21,1],
                  [1,7,15,14,1,-12,-12,1,14,15,7,1],
                  1)

def auri8p5(exp):
  return gen_auri(8,5,exp,10,[1,5,7,5,1],[1,2,2,1],2)

def auri8p7(exp):
  return gen_auri(8,7,exp,14,[1,7,3,-7,3,7,1],[1,2,-1,-1,2,1],2)

def auri9p2(exp):
  return gen_auri(9,2,exp,2,[1,1],[],3)

def auri9p7(exp):
  return gen_auri(9,7,exp,7,[1,3,3,1],[1,1,1],3)

def auri10p7(exp):
  return gen_auri(10,7,exp,70,
                  [1,35,228,770,1798,3255,4911,6545,8065,9450,10629,11445,11737,11445,10629,9450,8065,6545,4911,3255,1798,770,228,35,1],
                  [1,12,53,146,297,487,686,875,1049,1204,1326,1394,1394,1326,1204,1049,875,686,487,297,146,53,12,1],
                  1)

def auri11p2(exp):
  return gen_auri(11,2,exp,22,[1,11,27,33,21,11,21,33,27,11,1],
                  [1,4,7,6,3,3,6,7,4,1],1)

def auri11m3(exp):
  return gen_auri(11,3,exp,33,[1,16,37,19,-32,-59,-32,19,37,16,1],[1,5,6,-1,-9,-9,-1,6,5,1],1)

def auri11p4(exp):
  return gen_auri(11,4,exp,11,[1,5,-1,-1,5,1],[1,1,-1,1,1],2)

def auri11p5(exp):
  return gen_auri(11,5,exp,55,
                  [1,28,158,471,950,1419,1637,1472,1024,570,381,570,1024,1472,1637,1419,950,471,158,28,1],
                  [1,10,39,94,162,212,216,171,105,58,58,105,171,216,212,162,94,39,10,1], 1)

def auri11p6(exp):
  return gen_auri(11,6,exp,66,
                  [1,33,182,429,697,924,905,693,364,33,-73,33,364,693,905,924,697,429,182,33,1],
                  [1,11,37,69,102,117,100,67,22,-6,-6,22,67,100,117,102,69,37,11,1], 1)

def auri11p7(exp):
  return gen_auri(11,7,exp,77,
                  [1,38,202,178,-601,-952,749,2129,-102,-2759,-802,2434,1146,-1607,-505,1253,-505,-1607,1146,2434,-802,-2759,-102,2129,749,-952,-601,178,202,38,1],
                  [1,12,30,-15,-112,-37,202,165,-206,-271,131,273,-59,-176,82,82,-176,-59,273,131,-271,-206,165,202,-37,-112,-15,30,12,1], 1)

def auri11p8(exp):
  return gen_auri(11,8,exp,22,
                  [1,11,27,33,21,11,21,33,27,11,1],
                  [1,4,7,6,3,3,6,7,4,1],2)

def auri11p9(exp):
  return gen_auri(11,9,exp,11,
                  [1,5,-1,-1,5,1],[1,1,-1,1,1],3)

def auri11p10(exp):
  return gen_auri(11,10,exp,110,
                  [1,55,468,1210,488,-1925,-2169,440,2710,1430,-2541,-2090,1417,1870,482,-1155,-1066,275,-90,110,1041,110,-90,275,-1066,-1155,482,1870,1417,-2090,-2541,1430,2710,440,-2169,-1925,488,1210,468,55,1],
                  [1,18,83,111,-68,-240,-99,174,254,-62,-298,-18,197,120,-37,-138,-28,26,-24,70,70,-24,26,-28,-138,-37,120,197,-18,-298,-62,254,174,-99,-240,-68,111,83,18,1],
                  1)

def auri12p5(exp):
  return gen_auri(12,5,exp,15,[1,8,13,8,1],[1,3,3,1],2)

def auri12m7(exp):
  return gen_auri(12,7,exp,21,[1,10,13,7,13,10,1],[1,3,2,2,3,1],2)

def auri12m11(exp):
  return gen_auri(12,11,exp,33,[1,16,37,19,-32,-59,-32,19,37,16,1],[1,5,6,-1,-9,-9,-1,6,5,1],2)

aurifeuille = [[12,11,'-',33,auri12m11],
               [12,7,'-',21,auri12m7],
               [12,5,'+',15,auri12p5],
               [11,10,'+',110,auri11p10],
               [11,9,'+',11,auri11p9],
               [11,8,'+',22,auri11p8],
               [11,7,'+',77,auri11p7],
               [11,6,'+',66,auri11p6],
               [11,5,'+',55,auri11p5],
               [11,4,'+',11,auri11p4],
               [11,3,'-',33,auri11m3],
               [11,2,'+',22,auri11p2],
               [10,9,'+',10,auri10p9],
               [10,7,'+',70,auri10p7],
               [10,3,'+',30,auri10p3],
               [9,8,'+',2,auri9p8],
               [9,7,'+',7,auri9p7],
               [9,5,'-',5,auri9m5],
               [9,2,'+',2,auri9p2],
               [8,3,'+',6,auri8p3],
               [8,5,'+',10,auri8p5],
               [8,7,'+',14,auri8p7],
               [7,2,'+',14,auri7p2],
               [7,3,'-',21,auri7m3],
               [7,4,'+',7,auri7p4],
               [7,5,'+',35,auri7p5],
               [7,6,'+',42,auri7p6],
               [6,5,'+',30,auri6p5],
               [5,2,'+',10,auri5p2],
               [5,3,'+',15,auri5p3],
               [5,4,'-',5,auri5m4],
               [4,3,'+',3,auri4p3],
               [3,2,'+',6,auri3p2]]

def newname(oldparts, num):
  lx,exp,sgn,rx,exp_again = oldparts
  lx,exp,rx,exp_again = map(int, [lx, exp, rx, exp_again])
  # print lx,exp,rx,exp_again
  if (exp != exp_again):
    print "Malformed %s" % oldparts
  bigN = lx**exp+rx**exp if sgn=='+' else lx**exp-rx**exp
  if (bigN % num != 0):
    print "%s fails to divide %s in %s" % (num, bigN, oldparts)
    if (lx==3 and rx==2 and sgn=='-'):
      better_bigN = 3**exp+2**exp
      if (better_bigN % num == 0):
        print "Known fixup case"
        sgn = '+'
    else:
      sys.exit()
    
  for A in aurifeuille:
    if (A[0]==lx and A[1]==rx and A[2]==sgn):
      if (exp % (2*A[3]) == A[3]):
        #print "cheese %s" % A
        L,M=A[4](exp)
        #print L,M,num
        typ = "L" if (L%num==0) else "M" if (M%num==0) else "FAIL"
        if (typ == "FAIL"):
          print "Failed to identify %s in %s (%s,%s)" % (num,A,L,M)
          sys.exit()
        return "%s%s%s_%s%s" % (lx,sgn,rx,exp,typ)
        
  # not aurifeuillian, use new format
  return "%s%s%s_%s" % (lx, sgn, rx, exp)

ct = open("comps.tab.201811102359");
dat = {}

oldname_rx = re.compile("([0-9]+)\^([0-9]+)([+-])([0-9]+)\^([0-9]+)")

nidl = []

for line in ct:
  clist = line.split(":")
  n,nid,g,s,name,rtime,email,code = clist

# we want to rephrase the name in some special cases
  if (nid.find("_") == -1):
    r = oldname_rx.match(nid)
    if (r):
      rg = r.groups()
      nid = newname(rg, int(n))
      #print nid
    else:
      print "rx fail on ",nid

  if (nid in dat):
    print "Surprise duplicate of ",nid      
  dat[nid] = [n,float(g),float(s),name,rtime,email,code]
  nidl = nidl + [nid]
ct.close()

jb = open("jb.difficulties")
for line in jb:
  clist = line.split("\t")
  print [clist[0]]
  if (clist[0] in dat):
    print clist
    gd,sd,choice,degree = clist[1:5]
    if (sd == ''):
      sd=0.0
    gd,sd=map(float,[gd,sd])
    gdel = dat[clist[0]][1]-gd
    if (gdel>0 or gdel<-1):
      print "Possible mismatch for %s: GNFS difficulty %s not %s" % (clist[0], dat[clist[0]][1], gd)

    sdel = dat[clist[0]][2]-sd

    if (sdel != 0):
      print "SNFS mismatch for %s: difficulty %s not %s" % (clist[0], dat[clist[0]][2], sd)
      # trust JB's list
      if (sd!=0):
        dat[clist[0]][2] = sd
jb.close()

xx = open("comps.tab.new","w")
for nid in nidl:
  d = map(str,dat[nid])
  d = d[0:1]+[nid]+d[1:]
  xx.write((":".join(d)))
