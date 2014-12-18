#/bin/bash
##################################################################################################
# 7. HasFound (incremental updates)
##################################################################################################
# called withn bin/update_tables_ater_run.sh
# global variables defined in /etc/profile.d/cardiodb.sh
##################################################################################################

perl ${CARDIODB_ROOT}/bin/make_HasFound.pl --sql --db ${CARDIODB} --new_entries --check_alleles > ${CARDIODB_ROOT}/Dump/HasFound/HasFound.added.txt
mysqlimport --local --lock-tables --replace ${CARDIODB} ${CARDIODB_ROOT}/Dump/HasFound/HasFound.added.txt

perl ${CARDIODB_ROOT}/bin/make_HasFound.pl --sql --db ${CARDIODB} --new_entries > ${CARDIODB_ROOT}/Dump/HasFound/HasFound.added.colocated.txt
mysqlimport --local --lock-tables --ignore ${CARDIODB} ${CARDIODB_ROOT}/Dump/HasFound/HasFound.added.colocated.txt

time mysql ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_HasFound.hgmd_pro.is_new.sql

time mysql ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_HasFound.nectar.is_new.sql

echo Updating UnifiedCalls.has_found=1
time mysql ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_UnifiedCalls.has_found.sql
