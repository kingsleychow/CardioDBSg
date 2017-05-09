-- MySQL dump 10.13  Distrib 5.6.17, for linux-glibc2.5 (x86_64)
--
-- Host: 127.0.0.1    Database: cardiodbs_devel_test_fk
-- ------------------------------------------------------
-- Server version	5.6.17-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Callers`
--

DROP TABLE IF EXISTS `Callers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Callers` (
  `id` int(3) NOT NULL AUTO_INCREMENT,
  `caller` enum('Ensembl','GATK','LifeScope','Samtools','TorrentSuite','cgatools','UniProt','COSMIC','HGMD') NOT NULL,
  `version` varchar(100) NOT NULL,
  `is_current` tinyint(3) unsigned NOT NULL,
  `config_path` varchar(200) DEFAULT NULL,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `caller_UNIQUE` (`caller`,`version`,`is_current`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='Pre-fill table - to store the version of software/database used either for variant calling or annotations. Callers.id=Sample2Callers.caller_id.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `CodingEnrichments`
--

DROP TABLE IF EXISTS `CodingEnrichments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CodingEnrichments` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `sample_id` int(10) NOT NULL,
  `sample_name` varchar(100) NOT NULL,
  `hgnc` varchar(50) NOT NULL,
  `chr` varchar(5) NOT NULL,
  `cds_start` int(10) unsigned NOT NULL,
  `cds_end` int(10) unsigned NOT NULL,
  `callable_pct` float(5,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sample_id_only` (`sample_id`),
  KEY `cds_region` (`hgnc`,`cds_start`,`cds_end`),
  CONSTRAINT `fk_CodingEnrichments_Samples1` FOREIGN KEY (`sample_id`) REFERENCES `Samples` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=77017 DEFAULT CHARSET=utf8 COMMENT='Information extract from coverage report - PerOfCallableBy_ProteinCodingTarget_runname_poolname.txt. CodingEnrichments.sample_id=Samples.id.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ExtSources`
--

DROP TABLE IF EXISTS `ExtSources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ExtSources` (
  `source_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(24) NOT NULL,
  `version` int(11) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `type` enum('chip','lsdb') DEFAULT NULL,
  `somatic_status` enum('germline','somatic','mixed') DEFAULT 'germline',
  `data_types` set('variation','variation_synonym','structural_variation','phenotype_feature','study') DEFAULT NULL,
  PRIMARY KEY (`source_id`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8 COMMENT='Pre-filled table - external source to support HasFound. (mirror source table from ensembl_homo_sapiens_variation_75_37?)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GATKs`
--

DROP TABLE IF EXISTS `GATKs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GATKs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sample_id` int(11) NOT NULL,
  `variant_type` varchar(50) NOT NULL,
  `chr` varchar(50) NOT NULL,
  `v_start` int(11) NOT NULL,
  `v_end` int(11) NOT NULL,
  `reference` varchar(255) NOT NULL,
  `genotype` varchar(255) NOT NULL,
  `qual` float(8,2) DEFAULT NULL,
  `filter` varchar(255) DEFAULT NULL,
  `rs_id` varchar(255) DEFAULT NULL,
  `AB` varchar(10) DEFAULT NULL,
  `AC` varchar(10) DEFAULT NULL,
  `AF` varchar(12) DEFAULT NULL,
  `AN` int(5) DEFAULT NULL,
  `t_DP` int(5) DEFAULT NULL,
  `HRun` int(3) DEFAULT NULL,
  `MQ` float(5,2) DEFAULT NULL,
  `QD` float(5,2) DEFAULT NULL,
  `SB` float(7,2) DEFAULT NULL,
  `info` tinytext NOT NULL,
  `GT` char(3) NOT NULL,
  `AD` varchar(100) DEFAULT NULL,
  `f_DP` int(5) DEFAULT NULL,
  `GQ` float(5,2) DEFAULT NULL,
  `PL` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sample_id` (`sample_id`,`chr`,`v_start`,`v_end`,`reference`(100),`genotype`(100)),
  KEY `chr` (`chr`,`v_start`,`v_end`,`reference`(100),`genotype`(100)),
  KEY `sample_id_only` (`sample_id`),
  KEY `filter` (`filter`),
  CONSTRAINT `fk_GATKs_Samples1` FOREIGN KEY (`sample_id`) REFERENCES `Samples` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=36986 DEFAULT CHARSET=utf8 COMMENT='Information extract from result of GATK UnifiedGenotyper - samplename.markDup.Realigned.recalibrated.OnTarget.q15.bam.final.UnifiedGenotyper.snp.vcf and indel.vcf. GATKs.sample_id=Samples.id. GATKs.chr=_UnifiedCalls.chr & GATKs.v_start=_UnifiedCalls.v_start & GATKs.v_end=_UnifiedCalls.v_end & GATKs.reference=_UnifiedCalls.reference & GATKs.genotype=_UnifiedCalls.genotype';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`cardiodbs_admin`@`localhost`*/ /*!50003 TRIGGER `insert_UnifiedCalls_after_GATKs` AFTER INSERT ON `GATKs` FOR EACH ROW
BEGIN
	INSERT IGNORE INTO _UnifiedCalls
	SET chr=new.chr, v_start=new.v_start, v_end=new.v_end, reference=new.reference, genotype=new.genotype;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `GATKsHC`
--

DROP TABLE IF EXISTS `GATKsHC`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GATKsHC` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sample_id` int(11) NOT NULL,
  `variant_type` varchar(50) NOT NULL,
  `chr` varchar(50) NOT NULL,
  `v_start` int(11) NOT NULL,
  `v_end` int(11) NOT NULL,
  `reference` varchar(255) NOT NULL,
  `genotype` varchar(255) NOT NULL,
  `qual` float(8,2) DEFAULT NULL,
  `filter` varchar(255) DEFAULT NULL,
  `rs_id` varchar(255) DEFAULT NULL,
  `AB` varchar(10) DEFAULT NULL,
  `AC` varchar(10) DEFAULT NULL,
  `AF` varchar(12) DEFAULT NULL,
  `AN` int(5) DEFAULT NULL,
  `t_DP` int(5) DEFAULT NULL,
  `HRun` int(3) DEFAULT NULL,
  `HaplotypeScore` float DEFAULT NULL,
  `MQ` float(5,2) DEFAULT NULL,
  `QD` float(5,2) DEFAULT NULL,
  `SB` float(7,2) DEFAULT NULL,
  `info` tinytext NOT NULL,
  `GT` char(3) NOT NULL,
  `AD` varchar(100) DEFAULT NULL,
  `f_DP` int(5) DEFAULT NULL,
  `GQ` float(5,2) DEFAULT NULL,
  `PL` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sample_id` (`sample_id`,`chr`,`v_start`,`v_end`,`reference`(100),`genotype`(100)),
  KEY `chr` (`chr`,`v_start`,`v_end`,`reference`(100),`genotype`(100)),
  KEY `sample_id_only` (`sample_id`),
  KEY `filter` (`filter`),
  CONSTRAINT `fk_GATKsHC_Samples1` FOREIGN KEY (`sample_id`) REFERENCES `Samples` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=37648 DEFAULT CHARSET=utf8 COMMENT='Information extract from result of GATK HaplotypeCaller - samplename.markDup.Realigned.recalibrated.OnTarget.q15.bam.final.HaplotypeCaller.snp.vcf and indel.vcf. GATKsHC.sample_id=Samples.id. GATKsHC.chr=_UnifiedCalls.chr & GATKsHC.v_start=_UnifiedCalls.v_start & GATKsHC.v_end=_UnifiedCalls.v_end & GATKsHC.reference=_UnifiedCalls.reference & GATKsHC.genotype=_UnifiedCalls.genotype.';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`cardiodbs_admin`@`localhost`*/ /*!50003 TRIGGER `insert_UnifiedCalls_after_GATKsHC` AFTER INSERT ON `GATKsHC` FOR EACH ROW
BEGIN
	INSERT IGNORE INTO _UnifiedCalls
	SET chr=new.chr, v_start=new.v_start, v_end=new.v_end, reference=new.reference, genotype=new.genotype;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `HasFound`
--

DROP TABLE IF EXISTS `HasFound`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `HasFound` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(11) unsigned NOT NULL,
  `source_id` int(10) unsigned DEFAULT NULL,
  `xref` varchar(50) NOT NULL,
  `is_colocated` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `is_novel` (`uid`,`xref`),
  KEY `uid_only` (`uid`),
  KEY `source_id_only` (`source_id`),
  KEY `xref_only` (`xref`),
  CONSTRAINT `fk_HasFound_ExtSources1` FOREIGN KEY (`source_id`) REFERENCES `ExtSources` (`source_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_HasFound__UnifiedCalls1` FOREIGN KEY (`uid`) REFERENCES `_UnifiedCalls` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=109874 DEFAULT CHARSET=utf8 COMMENT='To tell where our variants are novel or not, co-located at the same genomics position of known variants or not, (co-located at the same codon affecting the same reference amino acid or not). is_colocated which could be: 0-exact same position and allele, 1-co-located at the genomic position, (2-co-located at the same codon).';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Runs`
--

DROP TABLE IF EXISTS `Runs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Runs` (
  `id` int(5) NOT NULL AUTO_INCREMENT,
  `run_name` varchar(100) NOT NULL,
  `date_of_seq` varchar(30) NOT NULL,
  `platform` varchar(50) NOT NULL,
  `machine` varchar(50) NOT NULL,
  `read_length` varchar(50) NOT NULL,
  `ISize` int(5) NOT NULL,
  `no_of_samples` int(5) NOT NULL,
  `indexing` int(5) NOT NULL,
  `index1_ID` varchar(50) DEFAULT NULL,
  `index2_ID` varchar(50) DEFAULT NULL,
  `run_type` varchar(100) DEFAULT NULL,
  `yield_GB` float(6,2) DEFAULT NULL,
  `q30_yield_GB` float(6,2) DEFAULT NULL,
  `q30_percent` float(6,2) DEFAULT NULL,
  `error_rate` float(6,2) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `run_name_UNIQUE` (`run_name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='Information from sequencing run. Runs.id=Samples.run_id';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Sample2Callers`
--

DROP TABLE IF EXISTS `Sample2Callers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Sample2Callers` (
  `id` int(3) NOT NULL AUTO_INCREMENT,
  `sample_id` int(5) NOT NULL,
  `caller_id` int(5) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sample2callers_UNIQUE` (`sample_id`,`caller_id`),
  KEY `fk_Sample2Callers_Callers1_idx` (`caller_id`),
  CONSTRAINT `fk_Sample2Callers_Callers1` FOREIGN KEY (`caller_id`) REFERENCES `Callers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_Sample2Callers_Samples1` FOREIGN KEY (`id`) REFERENCES `Samples` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8 COMMENT='Row filled by Samples table trigger. To link which samples are called or annotated by which (version of) caller or external sources. Samples2Callers.sample_id=Samples.id. Samples2Callers.caller_id=Callers.id.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SampleEnrichments`
--

DROP TABLE IF EXISTS `SampleEnrichments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SampleEnrichments` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `reportfile` tinytext NOT NULL,
  `sample_id` int(10) NOT NULL,
  `sample_name` varchar(100) NOT NULL,
  `total_read` int(10) unsigned NOT NULL,
  `mapped_read` int(10) unsigned NOT NULL,
  `mapped_pct` float(5,2) NOT NULL,
  `q15_mapped_read` int(10) unsigned NOT NULL,
  `q15_mapped_pct` float(5,2) NOT NULL,
  `q15_ontarget_read` int(10) unsigned NOT NULL,
  `q15_ontarget_pct` float(5,2) NOT NULL,
  `q15_ontarget_uniq_read` int(10) unsigned NOT NULL,
  `q15_ontarget_uniq_pct` float(5,2) NOT NULL,
  `mean_fwd_readlen` int(5) unsigned DEFAULT NULL,
  `mean_rev_readlen` int(5) unsigned DEFAULT NULL,
  `paired_read` int(10) unsigned DEFAULT NULL,
  `paired_pct` float(5,2) DEFAULT NULL,
  `strand_ratio` float(7,6) DEFAULT NULL,
  `enfactor` int(10) unsigned NOT NULL,
  `missed_exon` int(3) unsigned NOT NULL,
  `cov_0x_pct` float(5,2) NOT NULL,
  `cov_1x_pct` float(5,2) NOT NULL,
  `cov_5x_pct` float(5,2) NOT NULL,
  `cov_10x_pct` float(5,2) NOT NULL,
  `cov_20x_pct` float(5,2) NOT NULL,
  `cov_30x_pct` float(5,2) NOT NULL,
  `target_size` int(10) unsigned NOT NULL,
  `callable_base` int(10) unsigned NOT NULL,
  `callable_pct` float(5,2) NOT NULL,
  `cov_0x_base` int(10) unsigned NOT NULL,
  `cov_low_base` int(10) unsigned NOT NULL,
  `cov_excess_base` int(3) unsigned NOT NULL,
  `poor_quality` float(5,2) NOT NULL,
  `mean_cov` float(8,2) NOT NULL,
  `median_cov` int(10) unsigned NOT NULL,
  `max_cov` int(10) unsigned NOT NULL,
  `evenness_pct` float(5,2) NOT NULL,
  `snp_ts_tv_UnifiedG` decimal(4,2) DEFAULT NULL,
  `snp_ts_tv_HaplotypeC` decimal(4,2) DEFAULT NULL,
  `fastqc_read1_per_base_seq_qual` varchar(5) DEFAULT NULL,
  `fastqc_read1_per_seq_qual` varchar(5) DEFAULT NULL,
  `fastqc_read2_per_base_seq_qual` varchar(5) DEFAULT NULL,
  `fastqc_read2_per_seq_qual` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sample_id_UNIQUE` (`sample_id`),
  KEY `SampleEnrichSampleName_Samples_id_idx` (`sample_name`),
  CONSTRAINT `fk_SampleEnrichments_Samples1` FOREIGN KEY (`sample_id`) REFERENCES `Samples` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8 COMMENT='Information extract from coverage report - SummaryOutput_ProteinCodingTarget_runname.txt. SampleEnrichments.sample_id=Samples.id.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SampleStatus`
--

DROP TABLE IF EXISTS `SampleStatus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SampleStatus` (
  `id` int(5) NOT NULL AUTO_INCREMENT,
  `sample_id` int(5) NOT NULL,
  `status` varchar(500) NOT NULL DEFAULT 'NA',
  PRIMARY KEY (`id`),
  UNIQUE KEY `sample_id_UNIQUE` (`sample_id`),
  CONSTRAINT `fk_SampleStatus_Samples1` FOREIGN KEY (`id`) REFERENCES `Samples` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8 COMMENT='Row filled by Samples table trigger. A QC for samples. Non-OK = ?';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Samples`
--

DROP TABLE IF EXISTS `Samples`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Samples` (
  `id` int(5) NOT NULL AUTO_INCREMENT,
  `run_id` int(10) NOT NULL,
  `run_name` varchar(100) NOT NULL,
  `pool_name` varchar(100) NOT NULL,
  `sample_name` varchar(100) NOT NULL,
  `target_id` int(5) DEFAULT NULL,
  `target_code` varchar(255) DEFAULT NULL,
  `index1_ID` varchar(45) DEFAULT NULL,
  `index1` varchar(100) DEFAULT NULL,
  `index2_ID` varchar(45) DEFAULT NULL,
  `index2` varchar(100) DEFAULT NULL,
  `no_r1_cfilter` int(30) NOT NULL,
  `no_r2_cfilter` int(30) NOT NULL,
  `no_r1_qc` int(30) DEFAULT NULL,
  `no_r2_qc` int(30) DEFAULT NULL,
  `no_rp_qc` int(30) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `run_name_sample_name_UNIQUE` (`run_name`,`sample_name`,`target_id`),
  KEY `target_id_index` (`target_id`),
  KEY `sample_name_INDEX` (`sample_name`),
  KEY `run_name_only` (`run_name`),
  KEY `run_name_pool` (`run_name`,`pool_name`),
  KEY `run_id_only` (`run_id`),
  KEY `TargetCode_Samples_idx` (`target_code`),
  CONSTRAINT `fk_Samples_Runs` FOREIGN KEY (`run_id`) REFERENCES `Runs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_Samples_Targets1` FOREIGN KEY (`target_id`) REFERENCES `Targets` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8 COMMENT='Information for sequencing samples. Two triggers related with this table.';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`cardiodbs_admin`@`localhost`*/ /*!50003 TRIGGER `set_sample_status_before_insert` BEFORE INSERT ON `Samples`FOR EACH ROW 
BEGIN
	set @status='NA';
	IF new.run_name in (SELECT run_name FROM Runs WHERE run_name=new.run_name) THEN
		SET @status = 'OK';
	else
		SET @status = concat_ws(';', @status, 'no such run_name');
	end if;

	set NEW.run_id = (SELECT id FROM Runs WHERE run_name = new.run_name);
	set NEW.target_id = (SELECT id FROM Targets WHERE target_code = new.target_code);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`cardiodbs_admin`@`localhost`*/ /*!50003 TRIGGER `insert_sample2callers_sample_status_after_insert` AFTER INSERT ON `Samples` FOR EACH ROW
BEGIN
	insert ignore into Sample2Callers (sample_id,caller_id)
		SELECT s.id, c.id
		FROM Runs r, Samples s, Callers c
		WHERE s.id=NEW.id
		and r.run_name=s.run_name
		AND c.is_current=1 AND c.caller!='Ensembl'
		AND (CASE r.machine
			WHEN '454' THEN c.caller!='LifeScope' and c.caller!='TorrentSuite' and c.caller!='cgatools'
			WHEN '5500xl' THEN c.caller!='TorrentSuite' AND c.caller!='cgatools'
			WHEN 'SOLiD4' THEN c.caller!='LifeScope' AND c.caller!='TorrentSuite' AND c.caller!='cgatools'
			WHEN 'software' THEN c.caller!='TorrentSuite' AND c.caller!='cgatools'
			when 'CG' then c.caller='cgatools'
			WHEN 'MiSeq' THEN c.caller!='LifeScope' AND c.caller!='TorrentSuite' AND c.caller!='cgatools'
		END);
				
	insert ignore into SampleStatus (sample_id, status) values (new.id, @status);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Samtools`
--

DROP TABLE IF EXISTS `Samtools`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Samtools` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sample_id` int(11) NOT NULL,
  `variant_type` varchar(50) NOT NULL,
  `chr` varchar(50) NOT NULL,
  `v_start` int(11) NOT NULL,
  `v_end` int(11) NOT NULL,
  `reference` varchar(255) NOT NULL,
  `genotype` varchar(255) NOT NULL,
  `qual` float(8,2) DEFAULT NULL,
  `filter` varchar(255) DEFAULT NULL,
  `rs_id` varchar(255) DEFAULT NULL,
  `AF` float(3,2) DEFAULT NULL,
  `t_DP` int(5) DEFAULT NULL,
  `MQ` float(5,2) DEFAULT NULL,
  `info` tinytext NOT NULL,
  `GT` char(3) NOT NULL,
  `PL` varchar(200) DEFAULT NULL,
  `GQ` float(5,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sample_id` (`sample_id`,`chr`,`v_start`,`v_end`,`reference`(100),`genotype`(100)),
  KEY `chr` (`chr`,`v_start`,`v_end`,`reference`(100),`genotype`(100)),
  KEY `sample_id_only` (`sample_id`),
  CONSTRAINT `fk_Samtools_Samples1` FOREIGN KEY (`sample_id`) REFERENCES `Samples` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=34599 DEFAULT CHARSET=utf8 COMMENT='Information extract from result of samtools - samplename.markDup.Realigned.recalibrated.OnTarget.q15.bam.samtools.flt.vcf. Samtools.sample_id=Samples.id. Samtools.chr=_UnifiedCalls.chr and Samtools.v_start=_UnifiedCalls.v_start and Samtools.v_end=_UnifiedCalls.v_end and Samtools.reference=_UnifiedCalls.reference and Samtools.genotype=_UnifiedCalls.genotype.';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`cardiodbs_admin`@`localhost`*/ /*!50003 TRIGGER `insert_UnifiedCalls_after_Samtools` AFTER INSERT ON `Samtools` FOR EACH ROW
begin
	INSERT ignore INTO _UnifiedCalls
	set chr=new.chr, v_start=new.v_start, v_end=new.v_end, reference=new.reference, genotype=new.genotype;
end */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Targets`
--

DROP TABLE IF EXISTS `Targets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Targets` (
  `id` int(5) NOT NULL AUTO_INCREMENT,
  `target_code` varchar(255) NOT NULL,
  `target_name` varchar(255) NOT NULL,
  `designer` varchar(255) NOT NULL,
  `bed_path` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `target_id_UNIQUE` (`target_code`),
  UNIQUE KEY `target_name_UNIQUE` (`target_name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='Pre-fill table - assay information for target capture. Targets.id=Samples.target_id.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `V2Ensembls`
--

DROP TABLE IF EXISTS `V2Ensembls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `V2Ensembls` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(11) unsigned NOT NULL,
  `strand` int(1) DEFAULT NULL,
  `ensg` varchar(50) DEFAULT NULL,
  `hgnc` varchar(50) DEFAULT NULL,
  `ensg_type` varchar(50) DEFAULT NULL,
  `enst` varchar(50) DEFAULT NULL,
  `is_canonical` int(1) DEFAULT NULL,
  `enst_type` varchar(50) DEFAULT NULL,
  `t_start` int(11) NOT NULL DEFAULT '0',
  `t_end` int(11) NOT NULL DEFAULT '0',
  `cds_start` int(11) NOT NULL DEFAULT '0',
  `cds_end` int(11) NOT NULL DEFAULT '0',
  `codon` varchar(1000) DEFAULT NULL,
  `tr_allele` varchar(1000) DEFAULT NULL,
  `hgvs_coding` varchar(1000) DEFAULT NULL,
  `ccds` varchar(255) DEFAULT NULL,
  `so_terms` varchar(255) NOT NULL DEFAULT 'intergenic_variant',
  `rs_ids` varchar(255) DEFAULT NULL,
  `hgmds` tinytext,
  `cosmics` tinytext,
  `ensp` varchar(50) DEFAULT NULL,
  `p_start` int(5) DEFAULT NULL,
  `p_end` int(5) DEFAULT NULL,
  `p_ref` varchar(1000) DEFAULT NULL,
  `p_mut` varchar(1000) DEFAULT NULL,
  `hgvs_protein` varchar(1000) DEFAULT NULL,
  `sift` enum('tolerated','deleterious') DEFAULT NULL,
  `sift_score` float DEFAULT NULL,
  `pph_var` enum('unknown','benign','possibly damaging','probably damaging') DEFAULT NULL,
  `pph_var_score` float DEFAULT NULL,
  `pph_div` enum('unknown','benign','possibly damaging','probably damaging') DEFAULT NULL,
  `pph_div_score` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uid_enst_tstart_tend` (`uid`,`enst`,`t_start`,`t_end`),
  KEY `uid_only` (`uid`),
  KEY `hgnc_only` (`hgnc`),
  KEY `ensp_pstart_pend` (`ensp`,`p_start`,`p_end`),
  KEY `so_terms_only` (`so_terms`),
  CONSTRAINT `fk_V2Ensembls__UnifiedCalls1` FOREIGN KEY (`uid`) REFERENCES `_UnifiedCalls` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=866831 DEFAULT CHARSET=utf8 COMMENT='To store Ensembl VEP annotations. V2Ensembls.uid=_UnifiedCalls.id. V2Ensembls.id=V2Families.vid. V2Ensembls.id=_ClassifiedCalls.vid.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `V2Freqs`
--

DROP TABLE IF EXISTS `V2Freqs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `V2Freqs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(11) unsigned NOT NULL,
  `rs_id` varchar(50) NOT NULL,
  `allele` mediumtext,
  `frequency` float unsigned DEFAULT NULL,
  `count` int(11) unsigned DEFAULT NULL,
  `pop_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uid_rsid_allele_popid` (`uid`,`rs_id`,`allele`(200),`pop_id`),
  KEY `uid_only` (`uid`),
  KEY `rs_id_only` (`rs_id`),
  CONSTRAINT `fk_V2Freqs__UnifiedCalls1` FOREIGN KEY (`uid`) REFERENCES `_UnifiedCalls` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6378078 DEFAULT CHARSET=utf8 COMMENT='To store variant allele frequency. pop_id is from the population table of Ensembl Variation DB.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `V2Phens`
--

DROP TABLE IF EXISTS `V2Phens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `V2Phens` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(11) unsigned NOT NULL,
  `rs_id` varchar(50) NOT NULL,
  `des` varchar(255) DEFAULT NULL,
  `ex_ref` varchar(255) DEFAULT NULL,
  `p_value` double DEFAULT NULL,
  `risk_allele` varchar(255) DEFAULT NULL,
  `source` varchar(255) DEFAULT NULL,
  `study` varchar(255) DEFAULT NULL,
  `study_type` set('GWAS') DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uid_rsid_des` (`uid`,`rs_id`,`des`),
  KEY `uid_only` (`uid`),
  KEY `rs_id_only` (`rs_id`),
  CONSTRAINT `fk_V2Phens__UnifiedCalls1` FOREIGN KEY (`uid`) REFERENCES `_UnifiedCalls` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10608 DEFAULT CHARSET=utf8 COMMENT='Phenotype annotations from Ensembl.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `V2dbNSFP`
--

DROP TABLE IF EXISTS `V2dbNSFP`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `V2dbNSFP` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(11) unsigned NOT NULL,
  `nsfp_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uid_only` (`uid`),
  KEY `nsfp_id_only` (`nsfp_id`),
  CONSTRAINT `fk_V2dbNSFP__UnifiedCalls1` FOREIGN KEY (`uid`) REFERENCES `_UnifiedCalls` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Variants annotated by dbNSFP. ';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `V2dbSNPs`
--

DROP TABLE IF EXISTS `V2dbSNPs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `V2dbSNPs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(11) unsigned NOT NULL,
  `rs_id` varchar(50) NOT NULL,
  `allele_string` mediumtext,
  `ambi_code` char(1) DEFAULT NULL,
  `minor_allele` varchar(100) DEFAULT NULL,
  `ancestral_allele` varchar(255) DEFAULT NULL,
  `mac` int(10) unsigned DEFAULT NULL,
  `maf` float DEFAULT NULL,
  `validation` tinytext,
  `clinical_significance` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uid_rs_id` (`rs_id`,`uid`),
  KEY `uid_only` (`uid`),
  KEY `rs_id_only` (`rs_id`),
  CONSTRAINT `fk_V2dbSNPs__UnifiedCalls1` FOREIGN KEY (`uid`) REFERENCES `_UnifiedCalls` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=103770 DEFAULT CHARSET=utf8 COMMENT='Variants annotated by dbSNPs. V2dbSNPs.uid=_UnifiedCalls.id.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `_MetaCalls`
--

DROP TABLE IF EXISTS `_MetaCalls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `_MetaCalls` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sample_id` int(5) NOT NULL,
  `uid` int(11) unsigned NOT NULL,
  `gatk` int(11) unsigned DEFAULT NULL,
  `dp_gatk` int(11) unsigned DEFAULT NULL,
  `gatk_ug` int(11) unsigned DEFAULT NULL,
  `dp_gatk_ug` int(11) unsigned DEFAULT NULL,
  `gatk_hc` int(11) unsigned DEFAULT NULL,
  `dp_gatk_hc` int(11) unsigned DEFAULT NULL,
  `samtool` int(11) unsigned DEFAULT NULL,
  `dp_samtool` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sample_id_uid` (`uid`,`sample_id`),
  KEY `sample_id_only` (`sample_id`),
  KEY `uid_only` (`uid`),
  KEY `gatk_only` (`gatk`),
  KEY `gatk_hc_only` (`gatk_hc`),
  KEY `samtool_only` (`samtool`),
  CONSTRAINT `fk__MetaCalls_Samples1` FOREIGN KEY (`sample_id`) REFERENCES `Samples` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk__MetaCalls__UnifiedCalls1` FOREIGN KEY (`uid`) REFERENCES `_UnifiedCalls` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1656388 DEFAULT CHARSET=utf8 COMMENT='This table is a short-cut of joined results from Samples, _UnifiedCalls and various callers. _MetaCalls.sample_id=Samples.id. _MetaCalls.uid=_UnifiedCalls.id. _MetaCalls.gatk=GATKs.id';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `_UnifiedCalls`
--

DROP TABLE IF EXISTS `_UnifiedCalls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `_UnifiedCalls` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `chr` varchar(5) NOT NULL,
  `v_start` int(11) NOT NULL,
  `v_end` int(11) NOT NULL,
  `reference` varchar(1000) NOT NULL,
  `genotype` varchar(1000) NOT NULL,
  `in_ensembl` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `has_found` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `is_new` tinyint(3) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `chr_only` (`chr`),
  KEY `in_ensembl` (`in_ensembl`)
) ENGINE=InnoDB AUTO_INCREMENT=109231 DEFAULT CHARSET=utf8 COMMENT='Trigger-filled table - summarize variant information from different caller tables. To consolidate and merge variants regardless of callers. _UnifiedCalls.id=_MetaCalls.uid. _UnifiedCalls.id=V2Ensembls.uid. _UnifiedCalls.id=2PDBs.uid. _UnifiedCalls.id=2UniProts.uid. _UnifiedCalls.id=HasFound.uid. _UnifiedCalls.id=V2dbNSFP.uid.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'cardiodbs_devel_test_fk'
--
/*!50003 DROP PROCEDURE IF EXISTS `insert_metacalls_by_runname_new` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`cardiodbs`@`127.0.0.1` PROCEDURE `insert_metacalls_by_runname_new`(IN your_run_name VARCHAR(100))
BEGIN
	DECLARE stat VARCHAR(50);
	DECLARE my_platform VARCHAR(50);

	SET my_platform=(SELECT machine FROM Runs WHERE run_name=your_run_name);

	
	IF (my_platform='5500xl' OR my_platform='SOLiD4') THEN
		REPLACE INTO _MetaCalls (sample_id, uid, dibayes, dp_dibayes, smallindel, gatk, dp_gatk, gatk_hc, dp_gatk_hc, samtool, dp_samtool)
		SELECT p.id, u.id, d.id, d.coverage, i.id, g.id, g.t_DP, h.id, h.t_DP, s.id, s.t_DP
		FROM _UnifiedCalls u
		JOIN Samples p
		LEFT JOIN diBayes d ON u.chr=d.chr AND u.v_start=d.v_start AND u.v_end=d.v_end AND u.reference=d.reference AND u.genotype=d.genotype AND p.id=d.sample_id
		LEFT JOIN SmallIndels i ON u.chr=i.chr AND u.v_start=i.v_start AND u.v_end=i.v_end AND u.reference=i.reference AND u.genotype=i.genotype AND p.id=i.sample_id
		LEFT JOIN GATKs g ON u.chr=g.chr AND u.v_start=g.v_start AND u.v_end=g.v_end AND u.reference=g.reference AND u.genotype=g.genotype AND p.id=g.sample_id AND g.filter='PASS'
		LEFT JOIN GATKsHC h ON u.chr=h.chr AND u.v_start=h.v_start AND u.v_end=h.v_end AND u.reference=h.reference AND u.genotype=h.genotype AND p.id=h.sample_id AND h.filter='PASS'
		LEFT JOIN Samtools s ON u.chr=s.chr AND u.v_start=s.v_start AND u.v_end=s.v_end AND u.reference=s.reference AND u.genotype=s.genotype AND p.id=s.sample_id AND s.variant_type='SNP'

		
		WHERE (d.id OR g.id OR h.id OR s.id OR i.id)=1 AND p.run_name=your_run_name;
		SET stat='inserted';
	
	
	ELSEIF my_platform='CG' THEN
		REPLACE INTO _MetaCalls (sample_id, uid, cg, dp_cg)
		SELECT p.id, u.id, c.id, m.total_dp
		FROM _UnifiedCalls u
		JOIN Samples p
		LEFT JOIN CGvars c ON u.`chr`=c.`chr` AND u.`v_start`=c.`v_start` AND u.`v_end`=c.`v_end` AND u.`reference`=c.`reference` AND u.`genotype`=c.`genotype` AND p.id=c.sample_id 
		LEFT JOIN CGmastervars m ON c.`sample_id`=m.`sample_id` AND c.`locus`=m.`locus`
		
		WHERE c.id IS NOT NULL AND p.run_name=your_run_name;
		SET stat='inserted';

	
	ELSEIF (my_platform='MiSeq' OR my_platform='HiSeq' OR my_platform='454' OR my_platform='software') THEN
		REPLACE INTO _MetaCalls (sample_id, uid, gatk, dp_gatk, gatk_hc, dp_gatk_hc, samtool, dp_samtool)
		SELECT p.id, u.id, g.id, g.t_DP, h.id, h.t_DP, s.id, s.t_DP
		FROM _UnifiedCalls u
		JOIN Samples p
		LEFT JOIN GATKs g ON u.chr=g.chr AND u.v_start=g.v_start AND u.v_end=g.v_end AND u.reference=g.reference AND u.genotype=g.genotype AND p.id=g.sample_id AND g.filter='PASS'
		LEFT JOIN GATKsHC h ON u.chr=h.chr AND u.v_start=h.v_start AND u.v_end=h.v_end AND u.reference=h.reference AND u.genotype=h.genotype AND p.id=h.sample_id AND h.filter='PASS'
		LEFT JOIN Samtools s ON u.chr=s.chr AND u.v_start=s.v_start AND u.v_end=s.v_end AND u.reference=s.reference AND u.genotype=s.genotype AND p.id=s.sample_id AND s.variant_type='SNP'
		
		WHERE (g.id OR h.id or s.id)=1 AND p.run_name=your_run_name;
		SET stat='inserted';

	ELSE
		SET stat='no_such_platform';
	END IF;

	SELECT stat;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-12-12 15:12:38
