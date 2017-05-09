#/bin/bash
##################################################################################################
# 9. V2Ensembls (incremental updates)
##################################################################################################
# called withn bin/update_tables_ater_run.sh
# global variables defined in /etc/profile.d/cardiodb.sh
##################################################################################################

source /data2/users_data2/kingsley/CardioDBS/cardiodb.sh #ck

printf "perl ${CARDIODB_ROOT}/bin/make_V2Ensembls.pl --sql --db ${CARDIODB} --all --new_entries --v2ensx --annotation\n"
time perl ${CARDIODB_ROOT}/bin/make_V2Ensembls.pl --sql --db ${CARDIODB} --all --new_entries --v2ensx --annotation
#printf "perl ${CARDIODB_ROOT}/bin/make_V2Ensembls.pl --sql --db ${CARDIODB} --all --not_in_v2ensembl --v2ensx --annotation\n"
#time perl ${CARDIODB_ROOT}/bin/make_V2Ensembls.pl --sql --db ${CARDIODB} --all --not_in_v2ensembl --v2ensx --annotation
printf "mysqlimport --local --lock-tables --replace ${LOGIN} ${CARDIODB} ${CARDIODB_ROOT}/Dump/V2Ensembls/V2Ensembls.all.added.txt\n"
time mysqlimport --local --lock-tables --replace ${LOGIN} ${CARDIODB} ${CARDIODB_ROOT}/Dump/V2Ensembls/V2Ensembls.all.added.txt #ck
time mysqlimport --local --lock-tables --replace ${LOGIN} ${CARDIODB} ${CARDIODB_ROOT}/Dump/V2dbSNPs/V2dbSNPs.all.added.txt #ck
time mysqlimport --local --lock-tables --replace ${LOGIN} ${CARDIODB_ROOT}/Dump/V2Phens/V2Phens.all.added.txt #ck
time mysqlimport --local --lock-tables --replace ${LOGIN} ${CARDIODB} ${CARDIODB_ROOT}/Dump/V2Freqs/V2Freqs.all.added.txt #ck
echo Running V2Families...
# this will trigger 'insert_v2families_and_isnovel_after_v2ensembls' 
# However if V2Ensembls is repopuldated freshly, you should run SQL/V2Families.sql and SQL/IsNovel

