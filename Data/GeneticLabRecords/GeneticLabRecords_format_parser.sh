#!/bin/bash
dos2unix $1
awk -F ',' '{ print $1 }' $1 | sed -e 's/\//-/g' > $1.tmp1
awk -F ',' '{ print $3","$4 }' $1 > $1.tmp2
awk -F ',' '{ print $5 }' $1 | awk '{ print $1 }' | awk -F '/' '{ print $3"-"$1"-"$2 }' > $1.tmp3
awk -F ',' '{ print $6","$7","$8 }' $1 > $1.tmp4
paste -d , $1.tmp1 $1.tmp2 $1.tmp3 $1.tmp4 |  awk '{ print "0,"$0","}' > GeneticLabRecords.$1.final
rm $1.tmp*
