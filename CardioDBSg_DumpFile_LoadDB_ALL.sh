#!/bin/bash
#ALTER TABLE Runs AUTO_INCREMENT=1;
#convert file to linux format (from mac or window)
#CSV file with header from google spreadsheet
DESCRIPTION="Pipeline consists of (1)Prepare DumpFile for CardioDBSg (2)Load DumpFile into CardioDBSg"
DATE=`date +%Y-%m-%d`

#######################
##### Input Check #####
#######################
if [[ $# -lt 1 ]]
then
echo "##################################"
#echo "$PROGNAME Version $VERSION maintain by $MAINTAINER"
echo "$DESCRIPTION"
echo "Usage: $0 <config_file_fullpath>"
echo "#####"
echo "Example (Prepare DumpFile and Load DB): $0 ./cardiodbs.conf"
echo "##################################"
exit 1
fi

###################################
##### Read configuration file #####
###################################
CONFIG_FILE=$1

if [[ -f $CONFIG_FILE ]]; then
  . $CONFIG_FILE
fi

#####################################################
##### Prepare Dump File for DB and Loading Data #####
#####################################################
##### Create log folder #####
mkdir log_cardiodbs_$DATE

#########################################################
###### Update _UnifiedCalls table for existing data #####
#########################################################
echo "==================================="
echo "Update existing _UnifiedCalls table"
echo "==================================="
echo "Update _UnifiedCalls table for existing data prior to current run"

### _UnifiedCalls.is_new ###
printf "+++ Updating UnifiedCalls.is_new=0"
echo "### Update _UnifiedCalls.is_new=0 ###" >> log_cardiodbs_$DATE/mysql.$DATE.log
$MYSQL_PATH/bin/mysql --defaults-extra-file=$DB_CONFIG < ${CARDIODBS_PATH}/SQL/update_UnifiedCalls.is_new.sql
echo "" >> log_cardiodbs_$DATE/mysql.$DATE.log
echo " =====> Done!"

### _UnifiedCalls.in_ensembl ###
printf "+++ Updating UnifiedCalls.in_ensembl=1"
echo "### Update _UnifiedCalls.in_ensembl=1 ###" >> log_cardiodbs_$DATE/mysql.$DATE.log
$MYSQL_PATH/bin/mysql --defaults-extra-file=$DB_CONFIG < ${CARDIODBS_PATH}/SQL/update_UnifiedCalls.in_ensembl.sql
echo "" >> log_cardiodbs_$DATE/mysql.$DATE.log
echo " =====> Done!"

echo "================================="

########################
##### Current Runs #####
########################
for RUN in ${RUNS}; do 
	
	############################
	##### Runs and Samples #####
	############################
	echo "===================================="
	echo "=====${RUN}====="
	echo "===================================="
	printf "Copying CSV to Dump directory"
	
	### Dump file ###
	cp $(pwd)/Runs.${RUN}.csv $CARDIODBS_PATH/Dump/Runs/Runs.${RUN}.csv
	cp $(pwd)/Samples.${RUN}.csv $CARDIODBS_PATH/Dump/Samples/Samples.${RUN}.csv
	echo " =====> Done!"
	
	echo "Updating Runs and Samples"
	
	### Database ###
        printf "+++  Loading data into Runs"
	echo "### Loading data into Runs ###" >> log_cardiodbs_$DATE/mysqlimport.$DATE.$RUN.log
        $MYSQL_PATH/bin/mysqlimport --defaults-extra-file=$DB_CONFIG_IMPORT $DB --local --lock-tables --verbose --ignore --fields-terminated-by=',' --lines-terminated-by='\n' --ignore-lines=1 $CARDIODBS_PATH/Dump/Runs/Runs.${RUN}.csv >> log_cardiodbs_$DATE/mysqlimport.$DATE.$RUN.log 2>&1
	echo "" >> log_cardiodbs_$DATE/mysqlimport.$DATE.$RUN.log
        echo " =====> Done!"

        printf "+++  Loading data into Samples"
	echo "### Loading data into Samples ###" >> log_cardiodbs_$DATE/mysqlimport.$DATE.$RUN.log
        $MYSQL_PATH/bin/mysqlimport --defaults-extra-file=$DB_CONFIG_IMPORT $DB --local --lock-tables --verbose --ignore --fields-terminated-by=',' --lines-terminated-by='\n' --ignore-lines=1 $CARDIODBS_PATH/Dump/Samples/Samples.${RUN}.csv >> log_cardiodbs_$DATE/mysqlimport.$DATE.$RUN.log 2>&1
	echo "" >> log_cardiodbs_$DATE/mysqlimport.$DATE.$RUN.log
	echo " =====> Done!"
	echo "==================================="

	############################
	##### Differet Callers #####
	############################
	echo "Prepare ${CALLERS} dump file and update tables"
	
	for CALLER in ${CALLERS} ;
        do
	  ### Dump file ###
	  printf "+++  Preparing dump file for ${CALLER}"
	  PARSER=${CARDIODBS_PATH}/bin/make_${CALLER}.pl
	  echo "### Preparing dump file for ${CALLER} ###" >> log_cardiodbs_$DATE/${CALLER}.$DATE.$RUN.log
	  perl ${PARSER} --run_name ${RUN} --dbconfig $DB_CONFIG --miseq_result_path $MISEQ_PATH --nextseq_result_path $NEXTSEQ_PATH > ${CARDIODBS_PATH}/Dump/${CALLER}/${CALLER}.${RUN}.txt 2>> log_cardiodbs_$DATE/${CALLER}.$DATE.$RUN.log
	  echo " =====> Done!"

	  ### Database ###
	  printf "+++  Loading data into ${CALLER}"
          if [ -s ${CARDIODBS_PATH}/Dump/${CALLER}/${CALLER}.${RUN}.txt ]; then
		echo "### Loading data into ${CALLER} ###" >> log_cardiodbs_$DATE/mysqlimport.$DATE.$RUN.log
          	$MYSQL_PATH/bin/mysqlimport --defaults-extra-file=$DB_CONFIG_IMPORT $DB --local --lock-tables --verbose --replace ${CARDIODBS_PATH}/Dump/${CALLER}/${CALLER}.${RUN}.txt >> log_cardiodbs_$DATE/mysqlimport.$DATE.$RUN.log 2>&1
		echo "" >> log_cardiodbs_$DATE/mysqlimport.$DATE.$RUN.log
          	echo " =====> Done!";
	  fi
	done
	echo "=================================="
	
	###################################################
	##### SampleEnrichments and CodingEnrichments #####
	###################################################
	echo "Prepare SampleEnrichments and CodingEnrichments dump file and update tables"
	
	### Dump file ###	
	printf "+++  Preparing dump file for SampleEnrichments and CodingEnrichments"
	echo "### Preparing dump file for SampleEnrichments and CodingEnrichments ###" >> log_cardiodbs_$DATE/Enrichment.$DATE.$RUN.log
	perl ${CARDIODBS_PATH}/bin/make_Enrichments.pl --run_name $RUN --dbconfig $DB_CONFIG --CARDIODB_ROOT ${CARDIODBS_PATH} --miseq_result_path $MISEQ_PATH --nextseq_result_path $NEXTSEQ_PATH 2>> log_cardiodbs_$DATE/Enrichment.$DATE.$RUN.log
	echo " =====> Done!";
	
	### Database ###
	if [[ ${RUN} =~ "_M02463_" ]]; then
          printf "+++  Loading data into SampleEnrichments and CodingEnrichments"
	  echo "### Loading data into SampleEnrichments and CodingEnrichments ###" >> log_cardiodbs_$DATE/mysqlimport.$DATE.$RUN.log
          $MYSQL_PATH/bin/mysqlimport --defaults-extra-file=$DB_CONFIG_IMPORT $DB --local --lock-tables --verbose --replace ${CARDIODBS_PATH}/Dump/Enrichments/SampleEnrichments.${RUN}.txt >> log_cardiodbs_$DATE/mysqlimport.$DATE.$RUN.log 2>&1
          $MYSQL_PATH/bin/mysqlimport --defaults-extra-file=$DB_CONFIG_IMPORT $DB --local --lock-tables --verbose --replace ${CARDIODBS_PATH}/Dump/Enrichments/CodingEnrichments.${RUN}.txt >> log_cardiodbs_$DATE/mysqlimport.$DATE.$RUN.log 2>&1
	  echo "" >> log_cardiodbs_$DATE/mysqlimport.$DATE.$RUN.log
          echo " =====> Done!";
        fi

	echo "=================================="
	echo ""
done
	
####################
##### HasFound #####
####################
echo "###############"
echo "###############"
echo "Prepare HasFound dump file and update tables"

### Dump file ###
printf "+++  Preparing dump file for HasFound"
echo "### Preparing dump file for HasFound ###" >> log_cardiodbs_$DATE/HasFound.added.$DATE.log
perl ${CARDIODBS_PATH}/bin/make_HasFound.pl --sql --new_entries --check_alleles --dbconfig $DB_CONFIG --CARDIODB_ROOT ${CARDIODBS_PATH} --ens_api_conf $ENSEMBL_API > ${CARDIODBS_PATH}/Dump/HasFound/HasFound.added.txt 2>> log_cardiodbs_$DATE/HasFound.added.$DATE.log
echo "" >> log_cardiodbs_$DATE/HasFound.added.$DATE.log
echo " =====> Done!"

### Database ###
printf "+++  Loading data into HasFound"
echo "### Loading data into HasFound ###" >> log_cardiodbs_$DATE/mysqlimport.$DATE.log
$MYSQL_PATH/bin/mysqlimport --defaults-extra-file=$DB_CONFIG_IMPORT $DB --local --lock-tables --replace ${CARDIODBS_PATH}/Dump/HasFound/HasFound.added.txt >> log_cardiodbs_$DATE/mysqlimport.$DATE.log 2>&1
echo "" >> log_cardiodbs_$DATE/mysqlimport.$DATE.log
echo " =====> Done!"

##########################################
##### HasFound (Incremental Updates) #####
##########################################
echo "Preparing another dump file for HasFound and update table - Incremental"

### Dump file ###
printf "+++  Preparing dump file for HasFound - Incremental"
echo "### Preparing dump file for HasFound - Incremental ###" >> log_cardiodbs_$DATE/HasFound.added.$DATE.log
perl ${CARDIODBS_PATH}/bin/make_HasFound.pl --sql --new_entries --dbconfig $DB_CONFIG --CARDIODB_ROOT ${CARDIODBS_PATH} --ens_api_conf $ENSEMBL_API > ${CARDIODBS_PATH}/Dump/HasFound/HasFound.added.colocated.txt 2>> log_cardiodbs_$DATE/HasFound.added.$DATE.log
echo "" >> log_cardiodbs_$DATE/HasFound.added.$DATE.log
echo " =====> Done!"

### Database ###
printf "+++  Loading data into HasFound - Incremental"
echo "### Loading data into HasFound - Incremental ###" >> log_cardiodbs_$DATE/mysqlimport.$DATE.log
$MYSQL_PATH/bin/mysqlimport --defaults-extra-file=$DB_CONFIG_IMPORT $DB --local --lock-tables --ignore ${CARDIODBS_PATH}/Dump/HasFound/HasFound.added.colocated.txt >> log_cardiodbs_$DATE/mysqlimport.$DATE.log 2>&1
echo "" >> log_cardiodbs_$DATE/mysqlimport.$DATE.log
echo " =====> Done!"

echo "================================="

###############################################
##### _UnifiedCalls (Incremental Updates) #####
###############################################
echo "Updating _UnifiedCalls table - Incremental"

### Database ###
printf "+++  Update _UnifiedCalls table with HasFound - Incremental"
echo "### Update _UnifiedCalls table with HasFound - Incremental ###" >> log_cardiodbs_$DATE/mysql.$DATE.log
$MYSQL_PATH/bin/mysql --defaults-extra-file=$DB_CONFIG < ${CARDIODBS_PATH}/SQL/update_UnifiedCalls.has_found.sql >> log_cardiodbs_$DATE/mysql.$DATE.log 2>&1
echo "" >> log_cardiodbs_$DATE/mysql.$DATE.log
echo " =====> Done!"

echo "================================="

####################
##### V2dbNSFP #####
####################
echo "Updating V2dbNSFP table"

### Database ###
printf "+++  Update V2dbNSFP table with _UnifiedCalls and dbNSFP"
echo "### Update V2dbNSFP table with _UnifiedCalls and dbNSFP ###" >> log_cardiodbs_$DATE/mysql.$DATE.log
$MYSQL_PATH/bin/mysql --defaults-extra-file=$DB_CONFIG < ${CARDIODBS_PATH}/SQL/update_V2dbNSFP.sql >> log_cardiodbs_$DATE/mysql.$DATE.log 2>&1
echo "" >> log_cardiodbs_$DATE/mysql.$DATE.log
echo " =====> Done!"
echo "================================"

############################################
##### _MetaCalls (Incremental Updates) #####
############################################
echo "Updating _MetaCalls table"

### Database ###
printf "+++  Update _MetaCalls table with _UnifiedCalls and all Caller tables\n"
for RUN in ${RUNS} ; do
	printf "+++  Updating _MetaCalls for ${RUN}"
	echo "### Updating _MetaCalls for ${RUN} ###" >> log_cardiodbs_$DATE/mysql.$DATE.$RUN.log
	$MYSQL_PATH/bin/mysql --defaults-extra-file=$DB_CONFIG -e "call insert_metacalls_by_runname_new('${RUN}')" >> log_cardiodbs_$DATE/mysql.$DATE.$RUN.log 2>&1
	echo "" >> log_cardiodbs_$DATE/mysql.$DATE.$RUN.log
	echo " =====> Done!"
done

echo "================================"

############################################
##### V2Ensembls (Incremental Updates) #####
############################################
echo "Updating V2Ensembls, V2dbSNPs, V2Freqs and V2Phens table"

### Dump File ###
printf "+++  Preparing dump file for V2Ensembls, V2dbSNPs, V2Freqs and V2Phens - Incremental"
echo "### Preparing dump file for V2Ensembls, V2dbSNPs, V2Freqs and V2Phens - Incremental ###" >> log_cardiodbs_$DATE/V2Ensembls.$DATE.log
perl ${CARDIODBS_PATH}/bin/make_V2Ensembls.pl --sql --all --new_entries --v2ensx --annotation --dbconfig $DB_CONFIG --CARDIODB_ROOT ${CARDIODBS_PATH} --ens_api_conf $ENSEMBL_API  2>> log_cardiodbs_$DATE/V2Ensembls.$DATE.log
echo "" >> log_cardiodbs_$DATE/V2Ensembls.$DATE.log
echo " =====> Done!"

### Database ###
echo "+++  Loading data into V2Ensembls, V2dbSNPs, V2Freqs and V2Phens - Incremental"
printf "+++  Loading data into V2Ensembls - Incremental"
echo "### Loading data into V2Ensembls - Incremental ###" >> log_cardiodbs_$DATE/mysqlimport.$DATE.log
$MYSQL_PATH/bin/mysqlimport --defaults-extra-file=$DB_CONFIG_IMPORT $DB --local --lock-tables --replace ${CARDIODBS_PATH}/Dump/V2Ensembls/V2Ensembls.all.added.txt >> log_cardiodbs_$DATE/mysqlimport.$DATE.log 2>&1
echo "" >> log_cardiodbs_$DATE/mysqlimport.$DATE.log
echo " =====> Done!"

printf "+++  Loading data into V2dbSNPs - Incremental"
echo "### Loading data into V2dbSNPs - Incremental ###" >> log_cardiodbs_$DATE/mysqlimport.$DATE.log
$MYSQL_PATH/bin/mysqlimport --defaults-extra-file=$DB_CONFIG_IMPORT $DB --local --lock-tables --replace ${CARDIODBS_PATH}/Dump/V2dbSNPs/V2dbSNPs.all.added.txt >> log_cardiodbs_$DATE/mysqlimport.$DATE.log 2>&1
echo "" >> log_cardiodbs_$DATE/mysqlimport.$DATE.log
echo " =====> Done!"

printf "+++  Loading data into V2Phens - Incremental"
echo "### Loading data into V2Phens - Incremental ###" >> log_cardiodbs_$DATE/mysqlimport.$DATE.log
$MYSQL_PATH/bin/mysqlimport --defaults-extra-file=$DB_CONFIG_IMPORT $DB --local --lock-tables --replace ${CARDIODBS_PATH}/Dump/V2Phens/V2Phens.all.added.txt >> log_cardiodbs_$DATE/mysqlimport.$DATE.log 2>&1
echo "" >> log_cardiodbs_$DATE/mysqlimport.$DATE.log
echo " =====> Done!"

printf "+++  Loading data into V2Freqs - Incremental"
echo "### Loading data into V2Freqs - Incremental ###" >> log_cardiodbs_$DATE/mysqlimport.$DATE.log
$MYSQL_PATH/bin/mysqlimport --defaults-extra-file=$DB_CONFIG_IMPORT $DB --local --lock-tables --replace ${CARDIODBS_PATH}/Dump/V2Freqs/V2Freqs.all.added.txt >> log_cardiodbs_$DATE/mysqlimport.$DATE.log 2>&1
echo "" >> log_cardiodbs_$DATE/mysqlimport.$DATE.log
echo " =====> Done!"

echo "=============================="




###edit###
#time mysql ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_HasFound.hgmd_pro.is_new.sql
#time mysql ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_HasFound.nectar.is_new.sql
#echo Updating UnifiedCalls.has_found=1
#time mysql ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_UnifiedCalls.has_found.sql
###edit###
echo ""

