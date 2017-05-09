-- MySQL dump 10.13  Distrib 5.6.17, for linux-glibc2.5 (x86_64)
--
-- Host: 127.0.0.1    Database: cardiodbs_devel
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
  `is_current` int(1) NOT NULL,
  `config_path` varchar(200) DEFAULT NULL,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `caller_UNIQUE` (`caller`,`version`,`is_current`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `CodingEnrichments`
--

DROP TABLE IF EXISTS `CodingEnrichments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CodingEnrichments` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sample_id` int(10) unsigned NOT NULL,
  `sample_name` varchar(12) NOT NULL,
  `hgnc` varchar(50) NOT NULL,
  `chr` varchar(5) NOT NULL,
  `cds_start` int(10) unsigned NOT NULL,
  `cds_end` int(10) unsigned NOT NULL,
  `callable_pct` float(6,3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sample_cds_region` (`sample_id`,`hgnc`,`chr`,`cds_start`,`cds_end`),
  KEY `sample_id_only` (`sample_id`),
  KEY `sample_name_only` (`sample_name`),
  KEY `cds_region` (`hgnc`,`cds_start`,`cds_end`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
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
  `AB` float(3,2) DEFAULT NULL,
  `AC` int(5) DEFAULT NULL,
  `AF` float(3,2) DEFAULT NULL,
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
  KEY `filter` (`filter`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `insert_UnifiedCalls_after_GATKs` AFTER INSERT ON `GATKs` FOR EACH ROW
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
  `AB` float(3,2) DEFAULT NULL,
  `AC` int(5) DEFAULT NULL,
  `AF` float(3,2) DEFAULT NULL,
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
  KEY `filter` (`filter`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `insert_UnifiedCalls_after_GATKsHC` AFTER INSERT ON `GATKsHC` FOR EACH ROW
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
  `run_type` varchar(100) NOT NULL,
  `yield_GB` decimal(20,1) DEFAULT NULL,
  `q30_yield_GB` decimal(20,1) DEFAULT NULL,
  `q30_percent` decimal(20,2) DEFAULT NULL,
  `error_rate` decimal(20,2) DEFAULT NULL,
  `description` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `run_name_UNIQUE` (`run_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
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
  `caller_id` int(5) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sample2callers_UNIQUE` (`sample_id`,`caller_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
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
  `sample_id` int(10) unsigned NOT NULL,
  `sample_name` varchar(12) NOT NULL,
  `total_read` int(10) unsigned NOT NULL,
  `mapped_read` int(10) unsigned NOT NULL,
  `mapped_pct` float(6,3) NOT NULL,
  `q15_mapped_read` int(10) unsigned NOT NULL,
  `q15_mapped_pct` float(6,3) NOT NULL,
  `q15_ontarget_read` int(10) unsigned NOT NULL,
  `q15_ontarget_pct` float(6,3) NOT NULL,
  `q15_ontarget_uniq_read` int(10) unsigned NOT NULL,
  `q15_ontarget_uniq_pct` float(6,3) NOT NULL,
  `mean_fwd_readlen` int(5) unsigned DEFAULT NULL,
  `mean_rev_readlen` int(5) unsigned DEFAULT NULL,
  `paired_read` int(10) unsigned DEFAULT NULL,
  `paired_pct` float(6,3) DEFAULT NULL,
  `strand_ratio` float(7,6) DEFAULT NULL,
  `enfactor` int(10) unsigned NOT NULL,
  `missed_exon` int(3) unsigned NOT NULL,
  `cov_0x_pct` float(6,3) NOT NULL,
  `cov_1x_pct` float(6,3) NOT NULL,
  `cov_5x_pct` float(6,3) NOT NULL,
  `cov_10x_pct` float(6,3) NOT NULL,
  `target_size` int(10) unsigned NOT NULL,
  `callable_base` int(10) unsigned NOT NULL,
  `callable_pct` float(6,3) NOT NULL,
  `cov_0x_base` int(10) unsigned NOT NULL,
  `cov_low_base` int(10) unsigned NOT NULL,
  `cov_excess_base` int(3) unsigned NOT NULL,
  `poor_quality` float(6,3) NOT NULL,
  `mean_cov` float(10,3) NOT NULL,
  `median_cov` int(10) unsigned NOT NULL,
  `max_cov` int(10) unsigned NOT NULL,
  `evenness_pct` float(6,3) NOT NULL,
  `fastqc_read1_per_base_seq_qual` varchar(5) DEFAULT NULL,
  `fastqc_read1_per_seq_qual` varchar(5) DEFAULT NULL,
  `fastqc_read2_per_base_seq_qual` varchar(5) DEFAULT NULL,
  `fastqc_read2_per_seq_qual` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sample_id_UNIQUE` (`sample_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
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
  UNIQUE KEY `sample_id_UNIQUE` (`sample_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
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
  KEY `run_name_pool` (`run_name`,`pool_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `set_sample_status_before_insert` BEFORE INSERT ON `Samples`FOR EACH ROW 
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
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `insert_sample2callers_sample_status_after_insert` AFTER INSERT ON `Samples` FOR EACH ROW
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
  KEY `sample_id_only` (`sample_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `insert_UnifiedCalls_after_Samtools` AFTER INSERT ON `Samtools` FOR EACH ROW
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
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `_UnifiedCalls`
--

DROP TABLE IF EXISTS `_UnifiedCalls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `_UnifiedCalls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `chr` varchar(5) NOT NULL,
  `v_start` int(11) NOT NULL,
  `v_end` int(11) NOT NULL,
  `reference` varchar(1000) NOT NULL,
  `genotype` varchar(1000) NOT NULL,
  `in_ensembl` int(1) NOT NULL DEFAULT '0',
  `has_found` int(1) NOT NULL DEFAULT '0',
  `is_new` int(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `chr` (`chr`,`v_start`,`v_end`,`reference`(160),`genotype`(160)),
  KEY `chr_only` (`chr`),
  KEY `in_ensembl` (`in_ensembl`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-06-18 11:55:33
