USE cardiodbs_devel_test_ck;
UPDATE `_UnifiedCalls` u JOIN `V2Ensembls` v ON u.id=v.uid SET u.in_ensembl=1;
