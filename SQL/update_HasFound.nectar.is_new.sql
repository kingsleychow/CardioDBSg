/*
-- variants sharing the same codon
*/
INSERT IGNORE INTO CARDIODB_DEVEL.`HasFound`(uid,source_id,xref,is_colocated)
-- variants found in NECTAR
-- could be the same allele, co-located, or same codon variants
SELECT u.id, CASE f.feature 
			WHEN 'COSMIC' THEN 26 
			WHEN 'HUMSAVAR' THEN 99 
			WHEN  'HGMD-PUBLIC' THEN 0
			WHEN 'ClinVar' THEN 32 END AS source_id,
			IF(f.feature='COSMIC', concat('COSM',h.xref), h.xref) as xref, 
			2
FROM CARDIODB_DEVEL.`_UnifiedCalls` u
JOIN NECTAR.inSilicoSNVs i ON u.chr=i.chr AND u.v_start=i.v_start AND u.v_end=i.v_end AND u.reference=i.reference AND u.genotype=i.genotype
JOIN NECTAR.HPMDs h ON i.`ensp`=h.`ensp` AND i.`res_num`=h.`res_num`
JOIN NECTAR.featureDef f ON h.`fid`=f.`id`
WHERE u.is_new=1 -- new entries only
and f.`category`='Disease variants' -- HUMSAVAR, COSMIC, HGMD-PUBLIC, or ClinVar
