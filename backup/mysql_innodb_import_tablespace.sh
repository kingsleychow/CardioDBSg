#!/bin/bash
DB_CONFIG=/other/CardioDBS/backup/production_server.conf

#Discard existing tablespace
while read myline
do
  mysql --defaults-extra-file=$DB_CONFIG -e "ALTER TABLE $myline IMPORT TABLESPACE;"
done < $1
