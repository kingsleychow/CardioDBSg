#/bin/bash
# global variables defined in /etc/profile.d/cardiodb.sh
#######################################################################################
# 1. Update UnifiedCalls
echo Updating UnifiedCalls.is_new=0
printf "mysql ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_UnifiedCalls.is_new.sql\n"
time mysql ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_UnifiedCalls.is_new.sql
echo Updating _UnifiedCalls.in_ensembl=1...
printf "mysql ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_UnifiedCalls.in_ensembl.sql\n"
time mysql ${CARDIODB} < ${CARDIODB_ROOT}/SQL/update_UnifiedCalls.in_ensembl.sql
#######################################################################################
