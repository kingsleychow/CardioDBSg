-- this is to sync diag_code of Samples with that of BRU_DB

UPDATE Samples s 
JOIN PatPatients p ON s.bru_code=p.bru_code 
SET s.diag_code=IF(p.c_diag_code is null, p.`q_diag_code`, p.`c_diag_code`);
-- WHERE s.diag_code!=p.`c_diag_code`;

UPDATE Samples s 
JOIN GeneticsRecords p ON s.bru_code=p.bru_code 
SET s.diag_code=IF(p.c_diag_code is null, p.`q_diag_code`, p.`c_diag_code`);
-- WHERE s.diag_code!=p.`c_diag_code`;
