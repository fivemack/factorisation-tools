#!/bin/bash
NCPU=8
for u in $(seq 1 ${NCPU}); do mkdir dd$u; cp worktodo.ini dd$u; done
[ -e number ] || echo "-1" > number
w="";
for u in $(seq 1 ${NCPU}); do 
    ( while true; do 
	    with-lock-ex -w lockfile bash -ec 'B=`head number`; echo -n $[1+$B] > number';
	    ( B=`head number`; cd dd$u; /home/nfsworld/msieve-svn/trunk/msieve -v -np "$[1000*$B],$[1000*$B+1000]" >> eeyore; rm msieve.fb );
    done ) & 
    w="$w $!";
done
sleep 80000; kill -9 $w
