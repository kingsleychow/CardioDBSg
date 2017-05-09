#!/bin/bash
MYSQL_PATH=/other/mysql
CARDIODBS_PATH=/other/CardioDBS
DB_CONFIG_IMPORT=/other/CardioDBS/config/cardiodbs_login_import.conf
DB=cardiodbs_devel
name=NHCS-Rpt-Bioinformatics-Patient-List-with-Final-Diagnostics_20130805_20160115.csv.final

echo "### Loading data into BiobankRecords ###"
$MYSQL_PATH/bin/mysqlimport --defaults-extra-file=$DB_CONFIG_IMPORT $DB --local --lock-tables --verbose --replace --fields-terminated-by=',' --lines-terminated-by='\n' --ignore-lines=1 $CARDIODBS_PATH/Data/BiobankRecords/BiobankRecords.${name}
echo " =====> Done!"
