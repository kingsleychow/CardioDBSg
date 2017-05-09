#!/bin/bash
DB_CONFIG=/other/CardioDBS/backup/production_server.conf

#Discard existing tablespace
while read myline
do
  mysql --defaults-extra-file=$DB_CONFIG -e "SET FOREIGN_KEY_CHECKS = 0;ALTER TABLE $myline DISCARD TABLESPACE;SET FOREIGN_KEY_CHECKS = 1;"
done < $1
