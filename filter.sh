#!/bin/bash

ME=$(uname -n)
NCPU=1
CPUSET=0

case ${ME} in
    oak) NCPU=10;CPUSET=30-39;;
    pumpkin) NCPU=6;CPUSET=6-11;;
    pineapple) NCPU=14;CPUSET=14-27;;
    barley) NCPU=4;CPUSET=0-3;;
    butternut) NCPU=6;CPUSET=6-11;;
esac

echo "Running on ${ME} using ${NCPU} CPUs, namely ${CPUSET}"

echo "gzrecover..."
taskset -c ${CPUSET} gzrecover -o x1 *.dat.gz
echo "filtering out bad relations..."
LC_ALL=C taskset -c ${CPUSET} egrep -a '^-?[0-9]+,[0-9]+:[0-9a-fA-F,]+:[0-9a-fA-F,]+$' x1 | LC_ALL=C taskset -c ${CPUSET} egrep -av ",0:" > x2
wc -l x1 > corrupt-relation-count
wc -l x2 > uncorrupt-relation-count
echo "$(cat corrupt-relation-count) relations of which $(cat uncorrupt-relation-count) OK"
rm x1
echo "Uniquifying..."
LC_ALL=C taskset -c ${CPUSET} sort --parallel=${NCPU} -T. -t: -k1,1 -u x2 > msieve.dat
rm x2
taskset -c ${CPUSET} /home/nfsworld/aliquot-tools/determine-density.pl
