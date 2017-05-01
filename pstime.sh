grep elapsed */msieve.log | awk '{print $8}' | sed 's/:/ /g' | awk '{a+=(3600*$1+60*$2+$3)} END {print a}'
