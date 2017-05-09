#!/bin/bash
while read myline
do
  grep $myline $2
done < $1
