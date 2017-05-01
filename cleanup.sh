#!/bin/bash
for u in $(grep -El " (pr)?p[0-9]* factor" gnfs.*/msieve.log); do 
    B=${u#gnfs.}; B=${B%/msieve.log}
    short=C$(printf "%03d" ${#B}).${B:0:6}
    cp -p $u $short.mlog
done
grep -EHc " (pr)?p[0-9]* factor" gnfs.*/msieve.log | grep -v :0 | cut -d/ -f1  | xargs rm -rf
mv *mlog logs
