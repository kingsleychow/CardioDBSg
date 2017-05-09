#/bin/bash
##################################################################################################
# 7. HasFound (incremental updates)
##################################################################################################
# called withn bin/update_tables_ater_run.sh
# global variables defined in /etc/profile.d/cardiodb.sh
##################################################################################################

source /data2/users_data2/kingsley/CardioDBS/cardiodb.sh #ck

printf "perl ${CARDIODB_ROOT}/bin/make_HasFound.pl --sql --db ${CARDIODB} --new_entries --check_alleles > ${CARDIODB_ROOT}/Dump/HasFound/HasFound.added.txt\n" 
time perl ${CARDIODB_ROOT}/bin/make_HasFound.pl --sql --db ${CARDIODB} --new_entries --check_alleles > ${CARDIODB_ROOT}/Dump/HasFound/HasFound.added.txt
printf "mysqlimport --local --lock-tables --replace ${LOGIN} ${CARDIODB} ${CARDIODB_ROOT}/Dump/HasFound/HasFound.added.txt\n" #ck
time mysqlimport --local --lock-tables --replace ${LOGIN} ${CARDIODB} ${CARDIODB_ROOT}/Dump/HasFound/HasFound.added.txt #ck

printf "perl ${CARDIODB_ROOT}/bin/make_HasFound.pl --sql --db ${CARDIODB} --new_entries > ${CARDIODB_ROOT}/Dump/HasFound/HasFound.added.colocated.txt\n"
time perl ${CARDIODB_ROOT}/bin/make_HasFound.pl --sql --db ${CARDIODB} --new_entries > ${CARDIODB_ROOT}/Dump/HasFound/HasFound.added.colocated.txt
printf "mysqlimport --local --lock-tables --ignore ${LOGIN} ${CARDIODB} ${CARDIODB_ROOT}/Dump/HasFound/HasFound.added.colocated.txt\n" #ck
time mysqlimport --local --lock-tables --ignore ${LOGIN} ${CARDIODB} ${CARDIODB_ROOT}/Dump/HasFound/HasFound.added.colocated.txt #ck

printf "mysql ${LOGIN} ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_HasFound.hgmd_pro.is_new.sql\n" #ck
time mysql ${LOGIN} ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_HasFound.hgmd_pro.is_new.sql #ck

printf "mysql ${LOGIN} ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_HasFound.nectar.is_new.sql\n" #ck
time mysql ${LOGIN} ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_HasFound.nectar.is_new.sql #ck

echo Updating UnifiedCalls.has_found=1
printf "mysql ${LOGIN} ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_UnifiedCalls.has_found.sql\n" #ck
time mysql ${LOGIN} ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_UnifiedCalls.has_found.sql #ck
