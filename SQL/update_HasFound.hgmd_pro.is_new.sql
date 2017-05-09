-- source_id: 0 for 'hgmd_pro'
USE CARDIODB_DEVEL;

-- colocated HGMD
INSERT IGNORE INTO HasFound (uid, source_id, xref, is_colocated)
SELECT u.id, 0, c.`acc_num`, 1
FROM _UnifiedCalls u
JOIN CleanedHGMDs c ON u.chr=c.`chr` AND u.v_start=c.`g_start` AND u.v_end=c.`g_end`
where u.is_new=1;

-- exact alleles
REPLACE INTO HasFound (uid, source_id, xref, is_colocated)
SELECT u.id, 0, c.`acc_num`, 0
FROM _UnifiedCalls u
JOIN CleanedHGMDs c ON u.chr=c.`chr` AND u.v_start=c.`g_start` AND u.v_end=c.`g_end`
AND u.reference=IF(c.is_same_ref=0, c.genotype, c.reference)
AND u.genotype=IF(c.is_same_ref=0, c.reference, c.genotype)
where u.is_new=1;
