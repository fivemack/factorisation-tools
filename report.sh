for u in */*zot; do echo $u; tail -n2 ${u/zot/gpl}; echo report= > U; cat ${u/zot/ath}>>U; wget --post-file U -O /dev/null http://www.factordb.com/report.php ; rm U; done 
