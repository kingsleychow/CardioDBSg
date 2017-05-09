USE cardiodbs_devel_test_ck;
UPDATE `_UnifiedCalls` u SET u.is_new=0 where u.is_new=1;
