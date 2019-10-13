#!/bin/bash
set -e
#set -x

[ -e msieve.dat.chk ] && [ -e msieve.dat.bak.chk ] &&
    (
	T1=$(ls -l --time-style="+%s" msieve.dat.chk | awk '{print $6}')
	T0=$(ls -l --time-style="+%s" msieve.dat.bak.chk | awk '{print $6}')
	N=$(od -td4 msieve.dat.chk | head -n1 | awk '{print $2}')
	N1=$(od -td4 msieve.dat.chk | head -n1 | awk '{print $3}')
	N0=$(od -td4 msieve.dat.bak.chk | head -n1 | awk '{print $3}')
	TR=$[ ($N-$N1)*($T1-$T0)/($N1-$N0) ]
	ETA=$[ $T1+$TR ]
	date -d "@$ETA"
    )

[ $(echo *.s2 | wc -w) != 1 ] &&
    (
	NDONE=$(cat *.s2 | grep -c "Step 2")
	NTOT=$(for u in *.s2; do cat ${u%.s2}; done | wc -l)
	TLAST=$(ls -l --time-style="+%s" *.s2 | tail -n 1 | awk '{print $6}')
	TFIRST=$(for u in *.s2; do echo ${u%.s2}; done | xargs ls --time-style="+%s" -lrt | tail -n1 | awk '{print $6}')
	ETA=$[ $TFIRST + ($NTOT * ($TLAST-$TFIRST) / $NDONE) ]
	date -d "@$ETA"
    )
