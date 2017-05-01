#!/usr/bin/python
import urllib2
import re
import json
import sys
 
target_length = int(sys.argv[1])
 
base_url = 'http://dubslow.tk/aliquot/AllSeq.json'
s = json.load(urllib2.urlopen(base_url))
reo = re.compile(r'\&lt;')
re1 = re.compile(r'index.php.id=([0-9]*)')
re2 = re.compile(r'name=.query. value=.([0-9]*)')
for t in s["aaData"]:
 if (t[6]==target_length):
  url = 'http://factordb.com/index.php?id='+str(t[3])
  response = urllib2.urlopen(url)
  dat = response.read()
  sheep = dat.split("\n");
  for u in sheep:
   frog = reo.search(u)
   if frog:
    frog2 = re1.findall(u)
    big_factor_index=frog2[-1]
    url2 = 'http://factordb.com/index.php?id='+big_factor_index
    dat2 = urllib2.urlopen(url2).read().split("\n")
    for v in dat2:
     frog3 = re2.search(v)
     if frog3:
      cofactor = frog3.group(1)
      if (len(cofactor)==target_length):
       print cofactor
