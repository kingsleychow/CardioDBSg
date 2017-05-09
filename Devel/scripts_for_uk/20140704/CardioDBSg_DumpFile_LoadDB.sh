#!/bin/bash
#ALTER TABLE Runs AUTO_INCREMENT=1;
#convert file to linux format (from mac or window)
#CSV file with header from google spreadsheet
DESCRIPTION="Pipeline consists of (1)Prepare DumpFile for CardioDBSg (Runs and Samples will be loaded), (2)Load DumpFile into CardioDBSg"
DATE=`date +%Y-%m-%d`

#######################
##### Input Check #####
#######################
if [[ $# -lt 3 ]]
then
echo "##################################"
#echo "$PROGNAME Version $VERSION maintain by $MAINTAINER"
echo "$DESCRIPTION"
echo "Usage: $0 <config_file_fullpath> <Prepare DumpFile=[1|0]> <Load DB=[1|0]>"
echo "#####"
echo "Example (Prepare DumpFile and Load DB): $0 ./cardiodbs.conf 1 1"
echo "Example (Prepare DumpFile only): $0 ./cardiodbs.config 1 0"
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

############################################
##### Prepare Dump File for DB Loading #####
############################################
if [[ $2 == 1 ]]
then
  for RUN in ${RUNS}; do 
	
	##### Runs and Samples #####
	echo "=====${RUN}====="
	echo "====================="
	echo "Copying CSV to Dump directory..."
	
	cp $(pwd)/Runs.${RUN}.csv $CARDIODBS_PATH/Dump/Runs/Runs.${RUN}.csv
	cp $(pwd)/Samples.${RUN}.csv $CARDIODBS_PATH/Dump/Samples/Samples.${RUN}.csv

	echo "Updating Runs and Samples"

        echo "Loading data into Runs"
        $MYSQL_PATH/bin/mysqlimport --local --lock-tables --verbose --ignore --fields-terminated-by=',' --lines-terminated-by='\n' --ignore-lines=1 -h $DB_HOST -P $DB_PORT -u$DB_USER -p$DB_PASS $DB $CARDIODBS_PATH/Dump/Runs/Runs.${RUN}.csv >> mysqlimport.$DATE.$RUN.log 2>&1

        echo "Loading data into Samples"
        $MYSQL_PATH/bin/mysqlimport --local --lock-tables --verbose --ignore --fields-terminated-by=',' --lines-terminated-by='\n' --ignore-lines=1 -h $DB_HOST -P $DB_PORT -u$DB_USER -p$DB_PASS $DB $CARDIODBS_PATH/Dump/Samples/Samples.${RUN}.csv >> mysqlimport.$DATE.$RUN.log 2>&1

	echo "Done!"
	echo "====================="

	##### Different Callers #####
	echo "Prepare ${CALLERS} dump file..."
	
	for CALLER in ${CALLERS} ;
        do
	  printf "Preparing dump file for ${CALLER}\n"
	  PARSER=${CARDIODBS_PATH}/bin/make_${CALLER}.pl
	  perl ${PARSER} --run_name ${RUN} --db $DB --dbhost $DB_HOST --dbport $DB_PORT --dbuser $DB_USER --dbpass $DB_PASS > ${CARDIODBS_PATH}/Dump/${CALLER}/${CALLER}.${RUN}.txt 2>> ${CALLER}.$DATE.$RUN.log
	  printf "Done!\n";
	done
	echo "====================="
	
	##### SampleEnrichments and CodingEnrichments #####
	echo "Prepare SampleEnrichments and CodingEnrichments dump file..."
		
	printf "Preparing dump file for SampleEnrichments and CodingEnrichments\n"
	perl ${CARDIODBS_PATH}/bin/make_Enrichments.pl --run_name $RUN --db $DB --dbhost $DB_HOST --dbport $DB_PORT --dbuser $DB_USER --dbpass $DB_PASS --CARDIODB_ROOT ${CARDIODBS_PATH} 2>> Enrichment.$DATE.$RUN.log
	printf "Done!\n";
	echo "====================="
	echo ""
  done
fi

##################################
##### Load Dump File into DB #####
##################################
if [[ $3 == 1 ]]
then
  for RUN in ${RUNS}; do

	##### Different Callers #####
	echo "=====${RUN}====="
        echo "====================="
	echo "Updating ${CALLERS}"

	for CALLER in ${CALLERS} ;
	do
	  printf "Loading data into ${CALLER}\n"
	    if [ -s ${CARDIODBS_PATH}/Dump/${CALLER}/${CALLER}.${RUN}.txt ]; then
	      $MYSQL_PATH/bin/mysqlimport --local --lock-tables --verbose --replace -h $DB_HOST -P $DB_PORT -u$DB_USER -p$DB_PASS $DB ${CARDIODBS_PATH}/Dump/${CALLER}/${CALLER}.${RUN}.txt >> mysqlimport.$DATE.$RUN.log 2>&1
	      printf "Done!\n";
	      fi
	done
	echo "====================="
        	
	##### SampleEnrichments and CodingEnrichments #####
	echo "Updating SampleEnrichments and CodingEnrichments";
	
	if [[ ${RUN} =~ "_M02463_" ]]; then 
	  printf "Loading data into SampleEnrichments and CodingEnrichments\n"
	  $MYSQL_PATH/bin/mysqlimport --local --lock-tables --verbose --replace -h $DB_HOST -P $DB_PORT -u$DB_USER -p$DB_PASS $DB ${CARDIODBS_PATH}/Dump/Enrichments/SampleEnrichments.${RUN}.txt >> mysqlimport.$DATE.$RUN.log 2>&1 
	  $MYSQL_PATH/bin/mysqlimport --local --lock-tables --verbose --replace -h $DB_HOST -P $DB_PORT -u$DB_USER -p$DB_PASS $DB ${CARDIODBS_PATH}/Dump/Enrichments/CodingEnrichments.${RUN}.txt >> mysqlimport.$DATE.$RUN.log 2>&1
	  printf "Done!\n";
	fi
	echo "====================="
	echo ""
  done
fi

