#/bin/bash 

# Other global variables defined in /etc/profile.d/cardiodb.sh
source /data2/users_data2/kingsley/CardioDBS/cardiodb.sh #ck
# to export dependant perl modules
source /data2/users_data2/kingsley/CardioDBS/bioperl.sh #ck
#######################################################################################
# CONFIG
RUNS="140317_M02463_0009_000000000-A90GL"
PLATFORM='MiSeq' # 5500xl, MiSeq, HiSeq
TARGET_NAME='ICC_169Genes_DiagPanel' # for MiSeq only (e.g. see the table CARDIODB.Targets)
POOL='Nextera_169Gene' # for MiSeq only (e.g. /data/results/MiSeq/130927_M01389_0023_000000000-A5TF4/Piezo_HVOL_Fluidigm)
DATE=`date +%Y-%m-%d`
#######################################################################################

#######################################################################################
# 1. Update UnifiedCalls
printf "sh ${CARDIODB_ROOT}/bin/update_UnifiedCalls.sh \n"
#######################################################################################

for RUN in ${RUNS} ; do
	##################################################################################################
	# 2. insert Runs 
	##################################################################################################
	echo Updating Runs...
	printf "\t${RUN}\n"
	time mysql ${LOGIN} ${CARDIODB} -e "insert ignore into Runs(run_name, created, platform) values('$RUN','$DATE','$PLATFORM');"; #ck

	##################################################################################################
	# 3. insert Samples. This updates 'Sample2Callers' by the trigger 'insert_sample2caller_after_runs'
	# NB. only for CG, MiSeq and 5500xl at the moment.
	# for HiSeq, manually prepare your sample file to populate
	##################################################################################################
	echo Updating Samples...
	printf "perl ${CARDIODB_ROOT}/bin/make_Samples.pl --run_name $RUN --target ${TARGET_NAME} --pool ${POOL} > ${CARDIODB_ROOT}/Dump/Samples/Samples.${RUN}.txt\n"
	time perl ${CARDIODB_ROOT}/bin/make_Samples.pl --run_name $RUN --target ${TARGET_NAME} --pool ${POOL} > ${CARDIODB_ROOT}/Dump/Samples/Samples.${RUN}.txt
	printf "mysqlimport --local --lock-tables --verbose --replace  ${LOGIN} ${CARDIODB} ${CARDIODB_ROOT}/Dump/Samples/Samples.${RUN}.txt\n" #ck
	time mysqlimport --local --lock-tables --verbose --replace ${LOGIN}  ${CARDIODB} ${CARDIODB_ROOT}/Dump/Samples/Samples.${RUN}.txt #ck

	##################################################################################################
	# 4. run caller parsers and import them
	##################################################################################################
	echo Populating Callers...
	# if Complete Genomics
	if [[ ${RUN} =~ "^CG-" ]]; then
		time perl ${CARDIODB_ROOT}/bin/make_CGSamples.pl  --run_name ${RUN} > ${CARDIODB_ROOT}/Dump/Samples/Samples.${RUN}.txt
		time mysqlimport --local --lock-tables --verbose --ignore ${CARDIODB} ${CARDIODB_ROOT}/Dump/Samples/Samples.${RUN}.txt
		printf "ssh fs01 perl ${CARDIODB_ROOT}/bin/make_CGCalls_with_fork.pl --run_name ${RUN} --max_proc 6 --dump\n"
		time ssh fs01 perl ${CARDIODB_ROOT}/bin/make_CGCalls_with_fork.pl --run_name ${RUN} --max_proc 6 --dump

	# if not Complete Genomics (5500xl, MiSeq, HiSeq)
	else
		##################################################################################################
		# 5. Dumping varaints calls
		##################################################################################################
		# this will trigger 'insert_unified_calls_after_{CALLER}' (_UnifedCalls see below)
		# then will trigger 'insert_isnovels_after_unifiedcalls' (IsNovel after _UnifedCalls)
		# 'insert_isnovels_after_unifiedcalls' this is imperfect as it depends on using 'V2dbSNPs' table 
		# which could be updated later when 'bin/make_V2Ensembls.pl' is running
		for CALLER in ${CALLERS} ; do
			printf "${CALLER}\n"
			PARSER=${CARDIODB_ROOT}/bin/make_${CALLER}.pl

			printf "${PARSER} --run_name ${RUN} > ${CARDIODB_ROOT}/Dump/${CALLER}/${CALLER}.${RUN}.txt\n";
			time perl ${PARSER} --run_name ${RUN} > ${CARDIODB_ROOT}/Dump/${CALLER}/${CALLER}.${RUN}.txt
			printf "\n";

			if [ -s ${CARDIODB_ROOT}/Dump/${CALLER}/${CALLER}.${RUN}.txt ]; then
				printf "mysqlimport --local --lock-tables --verbose --replace  ${LOGIN} ${CARDIODB} ${CARDIODB_ROOT}/Dump/${CALLER}/${CALLER}.${RUN}.txt\n" #ck
				time mysqlimport --local --lock-tables --verbose --replace  ${LOGIN} ${CARDIODB} ${CARDIODB_ROOT}/Dump/${CALLER}/${CALLER}.${RUN}.txt #ck
				printf "\n";
			fi
	
		done
		##################################################################################################
		# 5. Coverage report (MiSeq only)
		##################################################################################################
		if [[ ${RUN} =~ "_M02463_" ]]; then #
			printf "perl ${CARDIODB_ROOT}/bin/make_Enrichments.pl --run_name $RUN \n"
			time perl ${CARDIODB_ROOT}/bin/make_Enrichments.pl --run_name $RUN 

			printf "mysqlimport --local --lock-tables --verbose --replace ${LOGIN}  ${CARDIODB} ${CARDIODB_ROOT}/Dump/Enrichments/SampleEnrichments.${RUN}.txt\n" #ck
			time mysqlimport --local --lock-tables --verbose --replace  ${LOGIN} ${CARDIODB} ${CARDIODB_ROOT}/Dump/Enrichments/SampleEnrichments.${RUN}.txt #ck
			printf "mysqlimport --local --lock-tables --verbose --replace  ${LOGIN} ${CARDIODB} ${CARDIODB_ROOT}/Dump/Enrichments/CodingEnrichments.${RUN}.txt\n" #ck
			time mysqlimport --local --lock-tables --verbose --replace ${LOGIN}  ${CARDIODB} ${CARDIODB_ROOT}/Dump/Enrichments/CodingEnrichments.${RUN}.txt #ck
		fi
	fi
done 

###################################
# 6. This updates 'Samples.diag_code' for BRU samples 
###################################
echo Updating Samples...
time mysql  ${LOGIN} ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_Samples.sql #ck

##################################################################################################
# 7. HasFound and V2dbNSFP (incremental updates)
##################################################################################################
echo Updating HasFound...
printf "sh ${CARDIODB_ROOT}/bin/update_HasFound.sh \n"
sh ${CARDIODB_ROOT}/bin/update_HasFound.sh 

echo Updating V2dbNSFP...
time mysql  ${LOGIN} ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_V2dbNSFP.sql #ck

##################################################################################################
# 8. _MetaCalls (incremental update only for the runs) 
##################################################################################################
for RUN in ${RUNS} ; do
	printf "Updating _MetaCalls for ${RUN}\n"
	# insert_metacalls_by_runname is a stored procedure
	time mysql  ${LOGIN} ${CARDIODB} -e "call insert_metacalls_by_runname_new('${RUN}')" & #ck
	# alternatively, you can use this:
	#time perl $CARDIODB_ROOT/bin/make_MetaCalls_with_fork.pl --run_name ${RUN} --dump
done

##################################################################################################
# 9. V2Ensembls (incremental updates)
##################################################################################################
echo Running V2Ensembls...
sh ${CARDIODB_ROOT}/bin/update_V2ENS.sh 

##################################################################################################
# 10. 2UniProts and 2PDBs
echo Updating 2UniProts and 2PDBs...
##################################################################################################
printf "mysql  ${LOGIN} ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_2UniProts.sql\n" #ck
time mysql  ${LOGIN} ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_2UniProts.sql & #ck
printf "mysql  ${LOGIN} ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_2PDBs.sql\n" #ck
time mysql  ${LOGIN} ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_2PDBs.sql #ck

##################################################################################################
# 11. the trigger 'insert_classifiedcalls_by_runname' is using various tables
# Among them, 'IsNovel' table
echo Updating ClassifiedCalls...
##################################################################################################
for RUN in ${RUNS} ; do
	printf "\tClassified Calls for ${RUN}\n"
	time mysql  ${LOGIN} ${CARDIODB} -e "call insert_classifiedcalls_by_runname('${RUN}')" & #ck
done 

##################################################################################################
# 12. 
#echo  updating MetaXX...
# this has been moved to cron jobs to save time
#time sh $CARDIODB_ROOT/bin/update_Meta.sh
##################################################################################################

echo Done
