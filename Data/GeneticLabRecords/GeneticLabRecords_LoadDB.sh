#!/bin/bash
MYSQL_PATH=/other/mysql
CARDIODBS_PATH=/other/CardioDBS
DB_CONFIG_IMPORT=/other/CardioDBS/config/cardiodbs_login_import.conf
DB=cardiodbs_devel
name=NHCS-Rpt-Bioinformatics-Genetic-Lab-Summary_20130917_20160115.csv.final
     
echo "### Loading data into GeneticLabRecords ###"
$MYSQL_PATH/bin/mysqlimport --defaults-extra-file=$DB_CONFIG_IMPORT $DB --local --lock-tables --verbose --replace --fields-terminated-by=',' --lines-terminated-by='\n' --ignore-lines=1 $CARDIODBS_PATH/Data/GeneticLabRecords/GeneticLabRecords.${name}
echo " =====> Done!"
