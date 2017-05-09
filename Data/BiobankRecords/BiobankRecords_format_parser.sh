#!/bin/bash
dos2unix $1
awk -F ',' '{ print $2 }' $1 | sed -e 's/\//-/g' > $1.tmp1
awk -F ',' '{ print $3 }' $1 | awk '{ print $1 }' | awk -F '/' '{ print $3"-"$1"-"$2 }' > $1.tmp2
awk -F ',' '{ print $4","$5","$6 }' $1 > $1.tmp3
paste -d , $1.tmp1 $1.tmp2 $1.tmp3 | awk '{ print "0,"$0}' > BiobankRecords.$1.final
rm *.tmp*
