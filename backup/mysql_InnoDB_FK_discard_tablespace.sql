SET FOREIGN_KEY_CHECKS = 0;
ALTER TABLE _MetaCalls DISCARD TABLESPACE;
ALTER TABLE BiobankRecords DISCARD TABLESPACE;
ALTER TABLE CodingEnrichments DISCARD TABLESPACE;
ALTER TABLE Diseases DISCARD TABLESPACE;
ALTER TABLE HasFound DISCARD TABLESPACE;
ALTER TABLE GATKs DISCARD TABLESPACE;
ALTER TABLE GATKsHC DISCARD TABLESPACE;
ALTER TABLE GeneticLabRecords DISCARD TABLESPACE;
ALTER TABLE projectas DISCARD TABLESPACE;
ALTER TABLE V2Ensembls DISCARD TABLESPACE;
ALTER TABLE V2Freqs DISCARD TABLESPACE;
ALTER TABLE V2Phens DISCARD TABLESPACE;
ALTER TABLE V2dbNSFP DISCARD TABLESPACE;
ALTER TABLE V2dbSNPs DISCARD TABLESPACE;
ALTER TABLE Sample2Callers DISCARD TABLESPACE;
ALTER TABLE SampleEnrichments DISCARD TABLESPACE;
ALTER TABLE SampleStatus DISCARD TABLESPACE;
ALTER TABLE Samtools DISCARD TABLESPACE;
ALTER TABLE ExtSources DISCARD TABLESPACE;
ALTER TABLE _UnifiedCalls DISCARD TABLESPACE;
ALTER TABLE Samples DISCARD TABLESPACE;
ALTER TABLE Runs DISCARD TABLESPACE;
ALTER TABLE Targets DISCARD TABLESPACE;
ALTER TABLE Callers DISCARD TABLESPACE;
SET FOREIGN_KEY_CHECKS = 1;
