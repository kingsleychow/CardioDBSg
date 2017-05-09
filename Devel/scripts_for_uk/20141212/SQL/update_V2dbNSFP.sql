INSERT IGNORE INTO cardiodbs_devel_test.`V2dbNSFP` (uid,nsfp_id)
SELECT u.`id`, d.`id`
FROM cardiodbs_devel_test.`_UnifiedCalls` u
JOIN dbNSFP.`core` d ON u.`chr`=concat('chr',d.`chr`) AND u.`v_start`=d.`pos` AND u.`v_end`=d.`pos` AND u.`reference`=d.`ref` AND u.`genotype`=d.`alt`
where u.`is_new`=1;
