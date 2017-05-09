-- MySQL dump 10.11
--
-- Host: fs01    Database: CARDIODB_DEVEL
-- ------------------------------------------------------
-- Server version	5.0.77-log

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
-- Table structure for table `2PDBs`
--

DROP TABLE IF EXISTS `2PDBs`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `2PDBs` (
  `id` int(11) NOT NULL auto_increment,
  `uid` int(11) unsigned NOT NULL,
  `2u_id` int(11) NOT NULL,
  `vid` int(11) NOT NULL,
  `res_id` int(11) NOT NULL,
  `pdb` char(4) NOT NULL,
  `chain` varchar(2) character set utf8 collate utf8_bin NOT NULL,
  `res_num` varchar(50) NOT NULL,
  `pdb_res` varchar(50) default NULL,
  `env` char(5) character set utf8 collate utf8_bin default NULL,
  `annotation` varchar(20) default NULL,
  `des` tinytext,
  `esst` int(2) default NULL,
  PRIMARY KEY  (`id`),
  KEY `uid` (`uid`),
  KEY `2u_id` (`2u_id`),
  KEY `vid` (`vid`),
  KEY `res_id` (`res_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `2UniProts`
--

DROP TABLE IF EXISTS `2UniProts`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `2UniProts` (
  `id` int(11) NOT NULL auto_increment,
  `uid` int(11) unsigned NOT NULL,
  `vid` int(11) NOT NULL,
  `p_ref` varchar(500) default NULL,
  `p_mut` varchar(500) default NULL,
  `ft_id` int(11) NOT NULL,
  `uniprot` char(6) NOT NULL,
  `res_num` int(5) NOT NULL,
  `uniprot_res` char(1) NOT NULL,
  `annotation` varchar(50) default NULL,
  `des` tinytext,
  `blosum62` int(2) default NULL,
  `pam70` int(2) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `vid` (`vid`,`ft_id`,`uniprot`,`res_num`),
  KEY `uid` (`uid`),
  KEY `vid_2` (`vid`),
  KEY `uniprot` (`uniprot`,`res_num`),
  KEY `annotation` (`annotation`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

/*!50003 SET @SAVE_SQL_MODE=@@SQL_MODE*/;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`sung`@`%` */ /*!50003 TRIGGER `insert_2pdb_after_2uniprot` AFTER INSERT ON `2UniProts` FOR EACH ROW BEGIN
						
			INSERT INTO 2PDBs (uid, 2u_id, vid, res_id, pdb, CHAIN, res_num, pdb_res, env, annotation, des)
			SELECT DISTINCT u.uid, u.id, u.vid, rm.res_id, rm.pdb, rm.pdb_chain_id, CONCAT_WS('', rm.pdb_res_num, rm.ins_code), rm.res_1code, ra.env, fr.type, 
			IF(fr.type='HUMSAVAR', CONCAT_WS(': ', fr.ext_id, fr.des), fr.des)
			FROM 2UniProts u
			JOIN GLORIA.ResMap rm ON u.uniprot=rm.uniprot AND u.res_num=rm.uniprot_res_num AND rm.pdb_res_num IS NOT NULL
			LEFT JOIN GLORIA.ResAnno ra ON ra.res_id=rm.res_id
			LEFT JOIN GLORIA.FuncRes fr ON fr.res_id=rm.res_id
			AND (fr.type!= 'CHAIN' AND fr.type!='DOMAIN' AND fr.type!='STRAND' AND fr.type!='HELIX' AND fr.type!='TURN' AND fr.type!='REPEAT' AND fr.type!='COMPBIAS'
			AND fr.type!='COILED' AND fr.type!='INIT_MET' AND fr.type!='NON_CONS' AND fr.type!='SAP' AND fr.type!='ENVAR')
			WHERE u.id=new.id;
		END */;;

DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@SAVE_SQL_MODE*/;

--
-- Table structure for table `CGSamples`
--

DROP TABLE IF EXISTS `CGSamples`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `CGSamples` (
  `id` int(10) NOT NULL auto_increment,
  `cg_sample_name` varchar(100) NOT NULL,
  `bru_code` char(9) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `cg_sample_name` (`cg_sample_name`),
  UNIQUE KEY `bru_code` (`bru_code`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `CGmastervars`
--

DROP TABLE IF EXISTS `CGmastervars`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `CGmastervars` (
  `id` int(11) NOT NULL auto_increment,
  `sample_id` int(11) NOT NULL,
  `locus` int(10) NOT NULL,
  `zygosity` char(10) NOT NULL,
  `var_type` char(10) NOT NULL,
  `reference` varchar(255) NOT NULL,
  `genotype1` varchar(255) NOT NULL,
  `genotype2` varchar(255) NOT NULL,
  `allele1_dp` int(10) default NULL,
  `allele2_dp` int(10) default NULL,
  `total_dp` int(10) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `sample_id` (`sample_id`,`locus`),
  KEY `sample_id_2` (`sample_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `CGmastervars_SORCS`
--

DROP TABLE IF EXISTS `CGmastervars_SORCS`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `CGmastervars_SORCS` (
  `id` int(11) NOT NULL auto_increment,
  `sample_id` int(11) NOT NULL,
  `locus` int(10) NOT NULL,
  `zygosity` char(10) NOT NULL,
  `var_type` char(10) NOT NULL,
  `reference` varchar(255) NOT NULL,
  `genotype1` varchar(255) NOT NULL,
  `genotype2` varchar(255) NOT NULL,
  `allele1_dp` int(10) default NULL,
  `allele2_dp` int(10) default NULL,
  `total_dp` int(10) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `sample_id` (`sample_id`,`locus`),
  KEY `sample_id_2` (`sample_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `CGvars`
--

DROP TABLE IF EXISTS `CGvars`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `CGvars` (
  `id` int(11) NOT NULL auto_increment,
  `sample_id` int(11) NOT NULL,
  `locus` int(10) NOT NULL,
  `allele_cnt` int(1) NOT NULL,
  `chr` varchar(5) NOT NULL,
  `v_start` int(11) NOT NULL,
  `v_end` int(11) NOT NULL,
  `variant_type` char(10) NOT NULL,
  `reference` varchar(255) NOT NULL,
  `genotype` varchar(255) NOT NULL,
  `vaf_score` int(10) NOT NULL,
  `eaf_score` int(10) NOT NULL,
  `qual` enum('H','L') NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `sample_id` (`sample_id`,`locus`,`allele_cnt`),
  KEY `sample_id_2` (`sample_id`),
  KEY `chr` (`chr`,`v_start`,`v_end`,`reference`(100),`genotype`(100))
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

/*!50003 SET @SAVE_SQL_MODE=@@SQL_MODE*/;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`sung`@`%` */ /*!50003 TRIGGER `insert_unifiedcalls_after_cgvars` AFTER INSERT ON `CGvars` FOR EACH ROW BEGIN
		INSERT IGNORE INTO _UnifiedCalls
		SET chr=new.chr, v_start=new.v_start, v_end=new.v_end, reference=new.reference, genotype=new.genotype;
    END */;;

DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@SAVE_SQL_MODE*/;

--
-- Table structure for table `CGvars_SORCS`
--

DROP TABLE IF EXISTS `CGvars_SORCS`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `CGvars_SORCS` (
  `id` int(11) NOT NULL auto_increment,
  `sample_id` int(11) NOT NULL,
  `locus` int(10) NOT NULL,
  `allele_cnt` int(1) NOT NULL,
  `chr` varchar(5) NOT NULL,
  `v_start` int(11) NOT NULL,
  `v_end` int(11) NOT NULL,
  `var_type` char(10) NOT NULL,
  `reference` varchar(255) NOT NULL,
  `genotype` varchar(255) NOT NULL,
  `vaf_score` int(10) NOT NULL,
  `eaf_score` int(10) NOT NULL,
  `qual` enum('H','L') NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `sample_id` (`sample_id`,`locus`,`allele_cnt`),
  KEY `sample_id_2` (`sample_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `Callers`
--

DROP TABLE IF EXISTS `Callers`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `Callers` (
  `id` int(3) NOT NULL auto_increment,
  `caller` enum('Ensembl','GATK','LifeScope','Samtools','TorrentSuite','cgatools','UniProt','COSMIC','HGMD') NOT NULL,
  `ver` varchar(100) NOT NULL,
  `is_current` int(1) NOT NULL,
  `config` text,
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `current` (`caller`,`ver`,`is_current`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `ClassifiedCalls`
--

DROP TABLE IF EXISTS `ClassifiedCalls`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `ClassifiedCalls` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `uid` int(11) unsigned NOT NULL,
  `vid` int(11) unsigned NOT NULL,
  `is_canonical` int(1) NOT NULL default '0',
  `which_level` enum('a','b','c','d') NOT NULL,
  `is_c1` int(1) NOT NULL,
  `is_c2` int(1) NOT NULL,
  `is_c3` int(1) NOT NULL,
  `avg_submat` float(4,3) default NULL,
  `avg_entropy` float(4,3) default NULL,
  `category` char(2) NOT NULL,
  `is_novel` int(1) NOT NULL default '1',
  `class` char(3) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `uid` (`uid`,`vid`),
  KEY `uid_2` (`uid`),
  KEY `vid` (`vid`),
  KEY `is_canonical` (`is_canonical`),
  KEY `class` (`class`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `CleanedHGMDs`
--

DROP TABLE IF EXISTS `CleanedHGMDs`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `CleanedHGMDs` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `acc_num` varchar(10) NOT NULL default '',
  `hgnc` varchar(10) default NULL,
  `mut_type` char(1) default NULL,
  `tag` enum('DP','FP','DFP','DM','DM?','FTV') default NULL,
  `disease` varchar(200) default NULL,
  `omim` int(8) unsigned default NULL,
  `pmid` int(8) unsigned default NULL,
  `hgvs_coding` varchar(200) default NULL,
  `chr` varchar(10) default NULL,
  `g_start` int(11) unsigned default NULL,
  `g_end` int(11) unsigned default NULL,
  `reference` varchar(150) default NULL,
  `genotype` varchar(150) default NULL,
  `is_same_ref` int(1) unsigned default NULL,
  `ens_ref` varchar(150) default NULL,
  `is_coord_from_ens` int(1) unsigned default '0',
  `is_pub` int(1) unsigned default '0',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `acc_num` (`acc_num`),
  KEY `chr` (`chr`,`g_start`,`g_end`,`reference`,`genotype`),
  KEY `is_pub` (`is_pub`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `CodingEnrichments`
--

DROP TABLE IF EXISTS `CodingEnrichments`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `CodingEnrichments` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `sample_id` int(10) unsigned NOT NULL,
  `sample_name` varchar(12) NOT NULL,
  `hgnc` varchar(50) NOT NULL,
  `chr` varchar(5) NOT NULL,
  `cds_start` int(10) unsigned NOT NULL,
  `cds_end` int(10) unsigned NOT NULL,
  `callable_pct` float(6,3) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `sample_cds_region` (`sample_id`,`hgnc`,`chr`,`cds_start`,`cds_end`),
  KEY `sample_id` (`sample_id`),
  KEY `sample_name` (`sample_name`),
  KEY `cds_region` (`hgnc`,`cds_start`,`cds_end`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `Diseases`
--

DROP TABLE IF EXISTS `Diseases`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `Diseases` (
  `id` int(5) unsigned NOT NULL auto_increment,
  `diag_code` varchar(20) default NULL,
  `des` varchar(500) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `diag_code` (`diag_code`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `DiskUsages`
--

DROP TABLE IF EXISTS `DiskUsages`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `DiskUsages` (
  `id` int(5) NOT NULL auto_increment,
  `dir` varchar(255) NOT NULL,
  `created` date NOT NULL,
  `size` bigint(20) unsigned NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `dir` (`dir`,`created`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `EnEntropies`
--

DROP TABLE IF EXISTS `EnEntropies`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `EnEntropies` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `fam_id` int(5) unsigned NOT NULL,
  `aln_pos` int(7) unsigned NOT NULL,
  `gap_freq` float(4,3) NOT NULL,
  `entropy` float(4,3) NOT NULL,
  `rel_entropy` float(4,3) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `fam_id` (`fam_id`,`aln_pos`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `EnFamilies`
--

DROP TABLE IF EXISTS `EnFamilies`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `EnFamilies` (
  `id` int(5) unsigned NOT NULL,
  `fam_name` varchar(20) NOT NULL,
  `des` tinytext,
  `des_score` int(3) unsigned default NULL,
  `mem_cnt` int(5) unsigned default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `fam_name` (`fam_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `EnMSAs`
--

DROP TABLE IF EXISTS `EnMSAs`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `EnMSAs` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `fam_id` int(5) unsigned NOT NULL,
  `mem_id` int(7) unsigned NOT NULL,
  `res` enum('A','C','D','E','F','G','H','I','J','K','L','M','N','P','Q','R','S','T','V','W','Y','X','*','-') default NULL,
  `aln_pos` int(7) unsigned NOT NULL,
  `res_num` int(7) unsigned default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `mem_id` (`mem_id`,`aln_pos`),
  KEY `mem_id_2` (`mem_id`,`aln_pos`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `EnMemberSources`
--

DROP TABLE IF EXISTS `EnMemberSources`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `EnMemberSources` (
  `id` int(1) NOT NULL,
  `source` varchar(20) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `EnMembers`
--

DROP TABLE IF EXISTS `EnMembers`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `EnMembers` (
  `id` int(7) unsigned NOT NULL,
  `fam_id` int(5) NOT NULL,
  `mem_name` varchar(20) NOT NULL,
  `taxon_id` int(7) unsigned default NULL,
  `source_id` int(1) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `mem_name` (`mem_name`),
  KEY `fam_id` (`fam_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `EnrichmentReports`
--

DROP TABLE IF EXISTS `EnrichmentReports`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `EnrichmentReports` (
  `id` int(10) NOT NULL auto_increment,
  `sample_id` int(10) NOT NULL,
  `bamfile` tinytext NOT NULL,
  `reportfile` tinytext NOT NULL,
  `bp_target` int(10) NOT NULL,
  `reads_on` int(10) NOT NULL,
  `reads_off` int(10) NOT NULL,
  `pct_reads_on` float(6,4) NOT NULL,
  `pct_reads_off` float(6,4) NOT NULL,
  `ratio_on_off` float(7,5) NOT NULL,
  `enrichment_fold` float(7,2) NOT NULL,
  `bp_target_null_coverage` int(10) NOT NULL,
  `pct_target_bp_not_covered` float(4,2) NOT NULL,
  `target_covered_1x` float(4,2) NOT NULL,
  `target_covered_5x` float(4,2) NOT NULL,
  `target_covered_10x` float(4,2) NOT NULL,
  `target_covered_20x` float(4,2) NOT NULL,
  `max_depth_of_target_coverage` float(7,2) NOT NULL,
  `avg_depth_of_target_coverage` float(7,2) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `sample_id` (`sample_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `ExtSources`
--

DROP TABLE IF EXISTS `ExtSources`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `ExtSources` (
  `source_id` int(10) unsigned NOT NULL,
  `name` varchar(24) NOT NULL,
  `version` int(11) default NULL,
  `description` varchar(255) default NULL,
  `url` varchar(255) default NULL,
  `somatic_status` enum('germline','somatic','mixed') default 'germline',
  PRIMARY KEY  (`source_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `GATKs`
--

DROP TABLE IF EXISTS `GATKs`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `GATKs` (
  `id` int(11) NOT NULL auto_increment,
  `sample_id` int(11) NOT NULL,
  `variant_type` varchar(50) NOT NULL,
  `chr` varchar(50) NOT NULL,
  `v_start` int(11) NOT NULL,
  `v_end` int(11) NOT NULL,
  `reference` varchar(255) NOT NULL,
  `genotype` varchar(255) NOT NULL,
  `qual` float(8,2) default NULL,
  `filter` varchar(255) default NULL,
  `rs_id` varchar(255) default NULL,
  `AB` float(3,2) default NULL,
  `AC` int(5) default NULL,
  `AF` float(3,2) default NULL,
  `AN` int(5) default NULL,
  `t_DP` int(5) default NULL,
  `HRun` int(3) default NULL,
  `MQ` float(5,2) default NULL,
  `QD` float(5,2) default NULL,
  `SB` float(7,2) default NULL,
  `info` tinytext NOT NULL,
  `GT` char(3) NOT NULL,
  `AD` varchar(100) default NULL,
  `f_DP` int(5) default NULL,
  `GQ` float(5,2) default NULL,
  `PL` varchar(200) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `sample_id` (`sample_id`,`chr`,`v_start`,`v_end`,`reference`(100),`genotype`(100)),
  KEY `chr` (`chr`,`v_start`,`v_end`,`reference`(100),`genotype`(100)),
  KEY `sample_id_2` (`sample_id`),
  KEY `filter` (`filter`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

/*!50003 SET @SAVE_SQL_MODE=@@SQL_MODE*/;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`sung`@`%` */ /*!50003 TRIGGER `insert_unifiedcalls_after_gatks` AFTER INSERT ON `GATKs` FOR EACH ROW BEGIN
		INSERT IGNORE INTO _UnifiedCalls
		SET chr=new.chr, v_start=new.v_start, v_end=new.v_end, reference=new.reference, genotype=new.genotype;
    END */;;

DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@SAVE_SQL_MODE*/;

--
-- Table structure for table `GATKsHC`
--

DROP TABLE IF EXISTS `GATKsHC`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `GATKsHC` (
  `id` int(11) NOT NULL auto_increment,
  `sample_id` int(11) NOT NULL,
  `variant_type` varchar(50) NOT NULL,
  `chr` varchar(50) NOT NULL,
  `v_start` int(11) NOT NULL,
  `v_end` int(11) NOT NULL,
  `reference` varchar(255) NOT NULL,
  `genotype` varchar(255) NOT NULL,
  `qual` float(8,2) default NULL,
  `filter` varchar(255) default NULL,
  `rs_id` varchar(255) default NULL,
  `AB` float(3,2) default NULL,
  `AC` int(5) default NULL,
  `AF` float(3,2) default NULL,
  `AN` int(5) default NULL,
  `t_DP` int(5) default NULL,
  `HRun` int(3) default NULL,
  `HaplotypeScore` float default NULL,
  `MQ` float(5,2) default NULL,
  `QD` float(5,2) default NULL,
  `SB` float(7,2) default NULL,
  `info` tinytext NOT NULL,
  `GT` char(3) NOT NULL,
  `AD` varchar(100) default NULL,
  `f_DP` int(5) default NULL,
  `GQ` float(5,2) default NULL,
  `PL` varchar(200) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `sample_id` (`sample_id`,`chr`,`v_start`,`v_end`,`reference`(100),`genotype`(100)),
  KEY `chr` (`chr`,`v_start`,`v_end`,`reference`(100),`genotype`(100)),
  KEY `sample_id_2` (`sample_id`),
  KEY `filter` (`filter`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

/*!50003 SET @SAVE_SQL_MODE=@@SQL_MODE*/;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`sung`@`%` */ /*!50003 TRIGGER `insert_unifiedcalls_after_gatksHC` AFTER INSERT ON `GATKsHC` FOR EACH ROW BEGIN
		INSERT IGNORE INTO _UnifiedCalls
		SET chr=new.chr, v_start=new.v_start, v_end=new.v_end, reference=new.reference, genotype=new.genotype;
    END */;;

DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@SAVE_SQL_MODE*/;

--
-- Table structure for table `GATKsMS`
--

DROP TABLE IF EXISTS `GATKsMS`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `GATKsMS` (
  `id` int(11) NOT NULL auto_increment,
  `group_name` varchar(100) NOT NULL,
  `gid` int(11) NOT NULL,
  `chr` varchar(50) NOT NULL,
  `variant_type` enum('SNP','Ins','Del') NOT NULL,
  `v_start` int(11) NOT NULL,
  `v_end` int(11) NOT NULL,
  `reference` varchar(500) NOT NULL,
  `genotype` varchar(255) NOT NULL,
  `qual` float(10,2) default NULL,
  `filter` varchar(255) default NULL,
  `rs_id` varchar(255) default NULL,
  `AB` float(3,2) default NULL,
  `AC` int(5) default NULL,
  `AF` float(3,2) default NULL,
  `AN` int(5) default NULL,
  `t_DP` int(5) default NULL,
  `HRun` int(3) default NULL,
  `QD` float(5,2) default NULL,
  `SB` float(7,2) default NULL,
  `info` text NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `group_name` (`group_name`,`gid`),
  KEY `v_start` (`v_start`),
  KEY `filter` (`filter`),
  KEY `rs_id` (`rs_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

/*!50003 SET @SAVE_SQL_MODE=@@SQL_MODE*/;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`sung`@`%` */ /*!50003 TRIGGER `insert_unifiedcalls_after_gatksMS` AFTER INSERT ON `GATKsMS` FOR EACH ROW BEGIN
		INSERT IGNORE INTO _UnifiedCalls
		SET chr=new.chr, v_start=new.v_start, v_end=new.v_end, reference=new.reference, genotype=new.genotype;
    END */;;

DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@SAVE_SQL_MODE*/;

--
-- Table structure for table `GATKsMSformat`
--

DROP TABLE IF EXISTS `GATKsMSformat`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `GATKsMSformat` (
  `id` int(11) NOT NULL auto_increment,
  `group_name` varchar(100) NOT NULL,
  `gid` int(11) NOT NULL,
  `sample_name` varchar(100) NOT NULL,
  `GT` char(3) default NULL,
  `AD` varchar(100) default NULL,
  `f_DP` int(5) default NULL,
  `GQ` float(5,2) default NULL,
  `PL` varchar(200) default NULL,
  PRIMARY KEY  (`id`),
  KEY `group_name` (`group_name`,`gid`,`sample_name`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `GATKsUG`
--

DROP TABLE IF EXISTS `GATKsUG`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `GATKsUG` (
  `id` int(11) NOT NULL auto_increment,
  `sample_id` int(11) NOT NULL,
  `variant_type` varchar(50) NOT NULL,
  `chr` varchar(50) NOT NULL,
  `v_start` int(11) NOT NULL,
  `v_end` int(11) NOT NULL,
  `reference` varchar(255) NOT NULL,
  `genotype` varchar(255) NOT NULL,
  `qual` float(8,2) default NULL,
  `filter` varchar(255) default NULL,
  `rs_id` varchar(255) default NULL,
  `AB` float(3,2) default NULL,
  `AC` int(5) default NULL,
  `AF` float(3,2) default NULL,
  `AN` int(5) default NULL,
  `t_DP` int(5) default NULL,
  `HRun` int(3) default NULL,
  `MQ` float(5,2) default NULL,
  `QD` float(5,2) default NULL,
  `SB` float(7,2) default NULL,
  `info` tinytext NOT NULL,
  `GT` char(3) NOT NULL,
  `AD` varchar(100) default NULL,
  `f_DP` int(5) default NULL,
  `GQ` float(5,2) default NULL,
  `PL` varchar(200) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `sample_id` (`sample_id`,`chr`,`v_start`,`v_end`,`reference`(100),`genotype`(100)),
  KEY `chr` (`chr`,`v_start`,`v_end`,`reference`(100),`genotype`(100)),
  KEY `sample_id_2` (`sample_id`),
  KEY `filter` (`filter`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

/*!50003 SET @SAVE_SQL_MODE=@@SQL_MODE*/;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`sung`@`%` */ /*!50003 TRIGGER `insert_unifiedcalls_after_gatksUG` AFTER INSERT ON `GATKsUG` FOR EACH ROW BEGIN
		INSERT IGNORE INTO _UnifiedCalls
		SET chr=new.chr, v_start=new.v_start, v_end=new.v_end, reference=new.reference, genotype=new.genotype;
    END */;;

DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@SAVE_SQL_MODE*/;

--
-- Table structure for table `GeneticsRecords`
--

DROP TABLE IF EXISTS `GeneticsRecords`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `GeneticsRecords` (
  `id` int(11) NOT NULL auto_increment,
  `bru_code` varchar(100) NOT NULL,
  `c_diag_code` varchar(10) default NULL,
  `q_diag_code` varchar(10) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `Groups`
--

DROP TABLE IF EXISTS `Groups`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `Groups` (
  `id` int(10) NOT NULL auto_increment,
  `group_name` varchar(100) NOT NULL,
  `sample_name` varchar(100) NOT NULL,
  `bru_code` char(9) NOT NULL,
  `is_family` enum('0','1') default NULL,
  `comment` tinytext,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `group_name` (`group_name`,`sample_name`),
  KEY `group_name_2` (`group_name`),
  KEY `sample_name` (`sample_name`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `HasFound`
--

DROP TABLE IF EXISTS `HasFound`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `HasFound` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `uid` int(11) unsigned NOT NULL,
  `source_id` int(2) NOT NULL,
  `xref` varchar(50) NOT NULL,
  `is_colocated` int(1) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `is_novel` (`uid`,`xref`),
  KEY `uid` (`uid`),
  KEY `xref` (`xref`),
  KEY `source_id` (`source_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `ICCRefs`
--

DROP TABLE IF EXISTS `ICCRefs`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `ICCRefs` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `mut_id` int(11) unsigned NOT NULL,
  `hgnc` varchar(50) default NULL,
  `enst` varchar(50) default NULL,
  `hgvs_coding` text NOT NULL,
  `chr` varchar(50) default NULL,
  `g_start` int(11) unsigned default NULL,
  `g_end` int(11) unsigned default NULL,
  `reference` varchar(150) default NULL,
  `genotype` varchar(100) default NULL,
  `strand` int(1) default NULL,
  `is_same_ref` int(1) default NULL,
  `is_same_coord` int(1) default NULL,
  `is_coord_from_icc` int(1) NOT NULL,
  `mut_path` varchar(400) default NULL,
  `exrefs` varchar(400) default NULL,
  `diseases` varchar(400) default NULL,
  `pubmeds` varchar(400) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `mut_id` (`mut_id`),
  KEY `chr` (`chr`,`g_start`,`g_end`,`reference`,`genotype`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `MergedSamples`
--

DROP TABLE IF EXISTS `MergedSamples`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `MergedSamples` (
  `id` int(10) NOT NULL auto_increment,
  `sid` int(10) NOT NULL,
  `merged_to` int(10) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `sid` (`sid`,`merged_to`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `MetaDiseases`
--

DROP TABLE IF EXISTS `MetaDiseases`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `MetaDiseases` (
  `id` int(3) unsigned NOT NULL,
  `diag_code` varchar(20) default NULL,
  `des` varchar(500) default NULL,
  `cnt_unique_run` int(5) NOT NULL,
  `cnt_unique_sample` int(5) NOT NULL,
  `cnt_unique_bru` int(5) NOT NULL,
  `cnt_unique_call` int(5) NOT NULL,
  `cnt_call` int(5) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `diag_code` (`diag_code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `MetaEnsembls`
--

DROP TABLE IF EXISTS `MetaEnsembls`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `MetaEnsembls` (
  `id` int(5) NOT NULL auto_increment,
  `sample_id` int(5) NOT NULL,
  `source` varchar(20) NOT NULL,
  `snp_type` varchar(255) NOT NULL,
  `num` int(10) NOT NULL default '0',
  `unique_variant` int(10) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `sample_id` (`sample_id`,`source`,`snp_type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `MetaGeneDiseases`
--

DROP TABLE IF EXISTS `MetaGeneDiseases`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `MetaGeneDiseases` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `hgnc` varchar(50) default NULL,
  `diag_code` varchar(20) NOT NULL,
  `cnt_unique_run` int(5) NOT NULL,
  `cnt_unique_sample` int(5) NOT NULL,
  `cnt_unique_bru` int(5) NOT NULL,
  `cnt_unique_call` int(5) NOT NULL,
  `cnt_call` int(5) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `hgnc` (`hgnc`),
  KEY `diag_code` (`diag_code`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `MetaGenes`
--

DROP TABLE IF EXISTS `MetaGenes`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `MetaGenes` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `hgnc` varchar(50) default NULL,
  `cnt_unique_run` int(5) NOT NULL,
  `cnt_unique_sample` int(5) NOT NULL,
  `cnt_unique_bru` int(5) NOT NULL,
  `cnt_unique_call` int(5) NOT NULL,
  `cnt_call` int(5) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `hgnc` (`hgnc`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `MetaPatientGenes`
--

DROP TABLE IF EXISTS `MetaPatientGenes`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `MetaPatientGenes` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `bru_code` char(9) NOT NULL,
  `diag_code` varchar(20) NOT NULL,
  `hgnc` varchar(51) default NULL,
  `cnt_unique_run` int(5) NOT NULL,
  `cnt_unique_sample` int(5) NOT NULL,
  `cnt_unique_call` int(10) NOT NULL,
  `cnt_call` int(10) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `bru_code` (`bru_code`,`diag_code`,`hgnc`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `MetaPatients`
--

DROP TABLE IF EXISTS `MetaPatients`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `MetaPatients` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `bru_code` char(9) NOT NULL,
  `diag_code` varchar(20) NOT NULL,
  `cnt_unique_gene` int(5) NOT NULL,
  `cnt_unique_run` int(5) NOT NULL,
  `cnt_unique_sample` int(5) NOT NULL,
  `cnt_unique_call` int(10) NOT NULL,
  `cnt_call` int(10) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `bru_code` (`bru_code`,`diag_code`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `MetaSamples`
--

DROP TABLE IF EXISTS `MetaSamples`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `MetaSamples` (
  `id` int(5) NOT NULL auto_increment,
  `sample_id` int(5) NOT NULL,
  `cnt_unique_call` int(10) NOT NULL,
  `dibayes` int(10) NOT NULL default '0',
  `indels` int(10) NOT NULL default '0',
  `gatks` int(10) NOT NULL default '0',
  `samtools` int(10) NOT NULL default '0',
  `cg` int(10) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `sample_id` (`sample_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `MetaSites`
--

DROP TABLE IF EXISTS `MetaSites`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `MetaSites` (
  `id` int(3) unsigned NOT NULL,
  `site_name` varchar(100) NOT NULL,
  `cnt_unique_run` int(5) NOT NULL,
  `cnt_unique_sample` int(5) NOT NULL,
  `cnt_unique_bru` int(5) NOT NULL,
  `cnt_unique_call` int(5) NOT NULL,
  `cnt_call` int(5) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `site_name` (`site_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `MetaTargetDiseases`
--

DROP TABLE IF EXISTS `MetaTargetDiseases`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `MetaTargetDiseases` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `target_name` varchar(100) NOT NULL,
  `diag_code` varchar(20) NOT NULL,
  `cnt_unique_run` int(5) NOT NULL,
  `cnt_unique_sample` int(5) NOT NULL,
  `cnt_unique_bru` int(5) NOT NULL,
  `cnt_unique_call` int(5) NOT NULL,
  `cnt_call` int(5) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `target_name` (`target_name`),
  KEY `diag_code` (`diag_code`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `MetaTargets`
--

DROP TABLE IF EXISTS `MetaTargets`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `MetaTargets` (
  `id` int(3) unsigned NOT NULL,
  `target_name` varchar(100) NOT NULL,
  `des` varchar(1000) default NULL,
  `cnt_unique_run` int(5) NOT NULL,
  `cnt_unique_sample` int(5) NOT NULL,
  `cnt_unique_bru` int(5) NOT NULL,
  `cnt_unique_call` int(5) NOT NULL,
  `cnt_call` int(5) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `target_name` (`target_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `PatPatients`
--

DROP TABLE IF EXISTS `PatPatients`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `PatPatients` (
  `id` int(11) NOT NULL auto_increment,
  `bru_code` varchar(100) NOT NULL,
  `q_diag_code` varchar(10) default NULL,
  `c_diag_code` varchar(10) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `Runs`
--

DROP TABLE IF EXISTS `Runs`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `Runs` (
  `id` int(5) NOT NULL auto_increment,
  `run_name` varchar(100) NOT NULL,
  `created` date NOT NULL,
  `platform` varchar(50) NOT NULL,
  `mask` varchar(50) default NULL,
  `is_multiplex` enum('TRUE','FALSE','N/A') default 'TRUE',
  `run_type` varchar(50) default NULL,
  `primer_info` varchar(100) default NULL,
  `des` text,
  `extra` text,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `run_name` (`run_name`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `Sample2Callers`
--

DROP TABLE IF EXISTS `Sample2Callers`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `Sample2Callers` (
  `id` int(3) NOT NULL auto_increment,
  `sample_id` int(5) NOT NULL,
  `caller_id` int(5) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `sample2caller` (`sample_id`,`caller_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `SampleEnrichments`
--

DROP TABLE IF EXISTS `SampleEnrichments`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `SampleEnrichments` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `reportfile` tinytext NOT NULL,
  `sample_id` int(10) unsigned NOT NULL,
  `sample_name` varchar(12) NOT NULL,
  `total_read` int(10) unsigned NOT NULL,
  `mapped_read` int(10) unsigned NOT NULL,
  `mapped_pct` float(6,3) NOT NULL,
  `q8_mapped_read` int(10) unsigned NOT NULL,
  `q8_mapped_pct` float(6,3) NOT NULL,
  `q8_ontarget_read` int(10) unsigned NOT NULL,
  `q8_ontarget_pct` float(6,3) NOT NULL,
  `q8_ontarget_uniq_read` int(10) unsigned NOT NULL,
  `q8_ontarget_uniq_pct` float(6,3) NOT NULL,
  `mean_fwd_readlen` int(5) unsigned default NULL,
  `mean_rev_readlen` int(5) unsigned default NULL,
  `paired_read` int(10) unsigned default NULL,
  `paired_pct` float(6,3) default NULL,
  `strand_ratio` float(7,6) default NULL,
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
  `fastqc_read1_per_base_seq_qual` varchar(5) default NULL,
  `fastqc_read1_per_seq_qual` varchar(5) default NULL,
  `fastqc_read2_per_base_seq_qual` varchar(5) default NULL,
  `fastqc_read2_per_seq_qual` varchar(5) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `sample_id` (`sample_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `SampleStatus`
--

DROP TABLE IF EXISTS `SampleStatus`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `SampleStatus` (
  `id` int(5) NOT NULL auto_increment,
  `sample_id` int(5) NOT NULL,
  `status` varchar(500) NOT NULL default 'NA',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `sample_id` (`sample_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `Samples`
--

DROP TABLE IF EXISTS `Samples`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `Samples` (
  `id` int(10) NOT NULL auto_increment,
  `run_id` int(10) unsigned NOT NULL,
  `run_name` varchar(100) NOT NULL,
  `pool_name` varchar(100) NOT NULL,
  `sample_name` varchar(100) NOT NULL,
  `bru_code` char(9) default NULL,
  `g_code` char(9) default NULL,
  `target_id` varchar(255) default NULL,
  `diag_code` varchar(20) default NULL,
  `barcode` varchar(50) NOT NULL default '1',
  `old_sample_name` varchar(100) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `barcode` (`run_name`,`pool_name`,`barcode`),
  UNIQUE KEY `run_name` (`run_name`,`sample_name`,`target_id`(100)),
  KEY `run_name_3` (`run_name`),
  KEY `sample_name` (`sample_name`),
  KEY `disease` (`diag_code`),
  KEY `bru_code` (`bru_code`),
  KEY `g_code` (`g_code`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

/*!50003 SET @SAVE_SQL_MODE=@@SQL_MODE*/;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`sung`@`%` */ /*!50003 TRIGGER `set_sample_status_before_samples` BEFORE INSERT ON `Samples` FOR EACH ROW BEGIN
		set @status='NA';
		
		IF new.run_name in (SELECT run_name FROM Runs WHERE run_name=new.run_name) THEN
			SET @status = 'OK';
		else
			SET @status = concat_ws(';', @status, 'no such run_name');
		end if;
		
		
		IF new.bru_code in (SELECT substr(new.sample_name, 1, 9)) THEN
			SET @status = 'OK';
		ELSE
			SET @status = CONCAT_WS(';', @status, 'bru_code is not sub string of sample');
		END IF;
		
		IF new.bru_code IN (SELECT g.bru_code FROM GeneticsRecords g UNION SELECT p.bru_code FROM PatPatients p) THEN 
			SET @status = 'OK';
		ELSE
			SET @status = CONCAT_WS(';', @status, 'bru_code not from BRU_DB');
		END IF;
		
		/*
		IF new.diag_code in (SELECT diag_code FROM Diseases WHERE diag_code=new.diag_code) THEN
			SET @status = 'OK';
		ELSE
			SET @status = CONCAT_WS(';', @status, 'no such diag_code');
		END IF;
				
		
		IF new.bru_code in (SELECT bru_code FROM Samples WHERE bru_code=new.bru_code AND diag_code!=new.diag_code)  then
			SET @status = CONCAT_WS(';', @status, 'same bru_code has different diag_code');
		else
			SET @status = 'OK';
		end if;
		
		if new.diag_code in (
			SELECT c_diag_code FROM PatPatients where bru_code=new.bru_code 
			UNION 
			SELECT c_diag_code diag_code FROM GeneticsRecords where bru_code=new.bru_code
		) Then
			set @status='OK';
		ELSE
			SET @status = CONCAT_WS(';', @status, 'diag_code not same from BRU_DB');
		end if;	
		*/
		
    END */;;

/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`sung`@`%` */ /*!50003 TRIGGER `insert_sample2callers_sample_status_after_samples` AFTER INSERT ON `Samples` FOR EACH ROW BEGIN
	
		-- 1. Samples2Callers
		insert ignore into Sample2Callers (sample_id,caller_id)
		SELECT s.id, c.id
		FROM Runs r, Samples s, Callers c
		WHERE s.id=NEW.id
		and r.run_name=s.run_name
		AND c.is_current=1 AND c.caller!='Ensembl'
		AND (CASE r.platform
			WHEN '454' THEN c.caller!='LifeScope' and c.caller!='TorrentSuite' and c.caller!='cgatools'
			WHEN '5500xl' THEN c.caller!='TorrentSuite' AND c.caller!='cgatools'
			WHEN 'SOLiD4' THEN c.caller!='LifeScope' AND c.caller!='TorrentSuite' AND c.caller!='cgatools'
			WHEN 'software' THEN c.caller!='TorrentSuite' AND c.caller!='cgatools'
			when 'CG' then c.caller='cgatools'
			WHEN 'MiSeq' THEN c.caller!='LifeScope' AND c.caller!='TorrentSuite' AND c.caller!='cgatools'
		END);
		
		-- 2. SampleStatus
		insert ignore into SampleStatus (sample_id, status) values (new.id, @status);
		
		-- 3. MergedSamples?
		/*
		INSERT INTO MergedSamples (sid, merged_to)
		SELECT s1.id, s2.id
		FROM Samples s1
		JOIN Samples s2 ON s1.bru_code=s2.bru_code AND s1.target_id=s2.target_id
		WHERE s1.run_name!=new.run_name
		AND s2.id=new.id
		*/
    END */;;

DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@SAVE_SQL_MODE*/;

--
-- Table structure for table `Samtools`
--

DROP TABLE IF EXISTS `Samtools`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `Samtools` (
  `id` int(11) NOT NULL auto_increment,
  `sample_id` int(11) NOT NULL,
  `variant_type` varchar(50) NOT NULL,
  `chr` varchar(50) NOT NULL,
  `v_start` int(11) NOT NULL,
  `v_end` int(11) NOT NULL,
  `reference` varchar(255) NOT NULL,
  `genotype` varchar(255) NOT NULL,
  `qual` float(8,2) default NULL,
  `filter` varchar(255) default NULL,
  `rs_id` varchar(255) default NULL,
  `AF` float(3,2) default NULL,
  `t_DP` int(5) default NULL,
  `MQ` float(5,2) default NULL,
  `info` tinytext NOT NULL,
  `GT` char(3) NOT NULL,
  `PL` varchar(200) default NULL,
  `GQ` float(5,2) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `sample_id` (`sample_id`,`chr`,`v_start`,`v_end`,`reference`(100),`genotype`(100)),
  KEY `chr` (`chr`,`v_start`,`v_end`,`reference`(100),`genotype`(100)),
  KEY `sample_id_2` (`sample_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

/*!50003 SET @SAVE_SQL_MODE=@@SQL_MODE*/;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`sung`@`%` */ /*!50003 TRIGGER `insert_unifiedcalls_after_samtools` AFTER INSERT ON `Samtools` FOR EACH ROW BEGIN
		INSERT ignore INTO _UnifiedCalls
		set chr=new.chr, v_start=new.v_start, v_end=new.v_end, reference=new.reference, genotype=new.genotype;
		
		/*
		UPDATE _UnifiedCalls u
		JOIN V2Ensembls v ON v.chr=new.chr AND v.g_start=new.v_start AND v.g_end=new.v_end AND v.reference=new.reference AND v.genotype=new.genotype
		SET u.in_ensembl=1;
		*/
    END */;;

DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@SAVE_SQL_MODE*/;

--
-- Table structure for table `SangerConfirm`
--

DROP TABLE IF EXISTS `SangerConfirm`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `SangerConfirm` (
  `sc_id` int(10) unsigned NOT NULL auto_increment,
  `sc_uid` int(11) unsigned NOT NULL,
  `sc_gene` varchar(20) NOT NULL,
  `sc_transcript` varchar(50) NOT NULL,
  `sc_codingvar` varchar(1000) NOT NULL,
  `sc_vartype` enum('missense','nonsense','frameshift','inframe indel','essential splice site','other splice site','non-coding','synonymous','complex indel','intronic') NOT NULL,
  `sc_patient_code` varchar(20) NOT NULL,
  `sc_sample` varchar(20) default NULL,
  `sc_primers` varchar(20) NOT NULL,
  `sc_detected` enum('Y','N') NOT NULL,
  `sc_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `sc_an_id` int(10) unsigned default NULL,
  `sc_curated_diagnosis` enum('Pathogenic','Putative Pathogenic','VUS','Benign','Not Detected') default NULL,
  `sc_ngs` enum('Y','N') default NULL,
  PRIMARY KEY  (`sc_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `Sites`
--

DROP TABLE IF EXISTS `Sites`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `Sites` (
  `id` int(2) NOT NULL,
  `site_name` varchar(100) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `SmallIndels`
--

DROP TABLE IF EXISTS `SmallIndels`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `SmallIndels` (
  `id` int(11) NOT NULL auto_increment,
  `sample_id` int(11) NOT NULL,
  `variant_type` varchar(50) NOT NULL,
  `chr` varchar(50) default NULL,
  `v_start` int(11) NOT NULL,
  `v_end` int(11) NOT NULL,
  `reference` varchar(1000) NOT NULL,
  `genotype` varchar(1000) NOT NULL,
  `allele_call` tinytext NOT NULL,
  `score` float(2,1) NOT NULL,
  `allele_count` varchar(100) default NULL,
  `no_nonred_reads` int(5) default NULL,
  `coverage_ratio` float(9,4) default NULL,
  `zygosity` varchar(100) NOT NULL,
  `zygosity_score` float(5,4) default NULL,
  `rs_ids` tinytext,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `sample_id` (`sample_id`,`chr`,`v_start`,`v_end`,`reference`(100),`genotype`(100)),
  KEY `chr` (`chr`,`v_start`,`v_end`,`reference`(100),`genotype`(100)),
  KEY `sample_id_2` (`sample_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

/*!50003 SET @SAVE_SQL_MODE=@@SQL_MODE*/;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`sung`@`%` */ /*!50003 TRIGGER `insert_unifiedcalls_after_smallindels` AFTER INSERT ON `SmallIndels` FOR EACH ROW BEGIN
		INSERT ignore INTO _UnifiedCalls
		set chr=new.chr, v_start=new.v_start, v_end=new.v_end, reference=new.reference, genotype=new.genotype;
		
		/*
		UPDATE _UnifiedCalls u
		JOIN V2Ensembls v ON v.chr=new.chr AND v.g_start=new.v_start AND v.g_end=new.v_end AND v.reference=new.reference AND v.genotype=new.genotype
		SET u.in_ensembl=1;
		*/
    END */;;

DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@SAVE_SQL_MODE*/;

--
-- Table structure for table `Tags`
--

DROP TABLE IF EXISTS `Tags`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `Tags` (
  `id` int(5) unsigned NOT NULL auto_increment,
  `tag` enum('DP','FP','DFP','DM','DM?','FTV') NOT NULL,
  `tag_name` varchar(500) NOT NULL,
  `des` text NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `tag` (`tag`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `TargetGenes`
--

DROP TABLE IF EXISTS `TargetGenes`;
/*!50001 DROP VIEW IF EXISTS `TargetGenes`*/;
/*!50001 CREATE TABLE `TargetGenes` (
  `id` int(11),
  `target_id` varchar(50),
  `hgnc` varchar(50),
  `ensg` varchar(50)
) ENGINE=MyISAM */;

--
-- Table structure for table `TargetRegions`
--

DROP TABLE IF EXISTS `TargetRegions`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `TargetRegions` (
  `id` int(11) NOT NULL auto_increment,
  `target_id` varchar(50) NOT NULL,
  `chr` varchar(50) NOT NULL,
  `g_start` int(11) NOT NULL,
  `g_end` int(11) NOT NULL,
  `hgnc` varchar(50) default NULL,
  `ensg` varchar(50) default NULL,
  `strand` int(1) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `target_region` (`target_id`,`chr`,`g_start`,`g_end`,`hgnc`,`ensg`),
  KEY `target_id` (`target_id`,`chr`,`g_start`,`g_end`),
  KEY `target_id_2` (`target_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `Targets`
--

DROP TABLE IF EXISTS `Targets`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `Targets` (
  `id` int(5) NOT NULL auto_increment,
  `target_id` varchar(255) NOT NULL,
  `target_name` varchar(255) NOT NULL,
  `designer` varchar(255) NOT NULL,
  `bed_file` varchar(255) NOT NULL,
  `des` varchar(1000) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `elid` (`target_id`),
  UNIQUE KEY `target` (`target_name`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `V2Ensembls`
--

DROP TABLE IF EXISTS `V2Ensembls`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `V2Ensembls` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `uid` int(11) unsigned NOT NULL,
  `strand` int(1) default NULL,
  `ensg` varchar(50) default NULL,
  `hgnc` varchar(50) default NULL,
  `ensg_type` varchar(50) default NULL,
  `enst` varchar(50) default NULL,
  `is_canonical` int(1) default NULL,
  `enst_type` varchar(50) default NULL,
  `t_start` int(11) NOT NULL default '0',
  `t_end` int(11) NOT NULL default '0',
  `cds_start` int(11) NOT NULL default '0',
  `cds_end` int(11) NOT NULL default '0',
  `codon` varchar(1000) default NULL,
  `tr_allele` varchar(1000) default NULL,
  `hgvs_coding` varchar(1000) default NULL,
  `ccds` varchar(255) default NULL,
  `so_terms` varchar(255) NOT NULL default 'intergenic_variant',
  `rs_ids` varchar(255) default NULL,
  `hgmds` tinytext,
  `cosmics` tinytext,
  `ensp` varchar(50) default NULL,
  `p_start` int(5) default NULL,
  `p_end` int(5) default NULL,
  `p_ref` varchar(1000) default NULL,
  `p_mut` varchar(1000) default NULL,
  `hgvs_protein` varchar(1000) default NULL,
  `sift` enum('tolerated','deleterious') default NULL,
  `sift_score` float default NULL,
  `pph_var` enum('unknown','benign','possibly damaging','probably damaging') default NULL,
  `pph_var_score` float default NULL,
  `pph_div` enum('unknown','benign','possibly damaging','probably damaging') default NULL,
  `pph_div_score` float default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `uid_2` (`uid`,`enst`,`t_start`,`t_end`),
  KEY `uid` (`uid`),
  KEY `hgnc` (`hgnc`),
  KEY `ensp` (`ensp`,`p_start`,`p_end`),
  KEY `so_terms` (`so_terms`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

/*!50003 SET @SAVE_SQL_MODE=@@SQL_MODE*/;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`sung`@`%` */ /*!50003 TRIGGER `insert_v2fam_and_2uniProt_after_v2ensembls` AFTER INSERT ON `V2Ensembls` FOR EACH ROW BEGIN
	
		/*
		-- 1. insert V2Families
		*/
		INSERT IGNORE INTO V2Families (vid, mem_id, fam_id, aln_pos, res_num)
		SELECT NEW.id, a.mem_id, f.id, a.aln_pos, a.res_num
		FROM EnMSAs a
		JOIN EnMembers m ON a.mem_id=m.id
		JOIN EnFamilies f ON m.fam_id=f.id
		WHERE NEW.ensp=m.mem_name AND a.res_num BETWEEN NEW.p_start AND NEW.p_end
		AND NEW.ensp IS NOT NULL AND NEW.p_start IS NOT NULL AND NEW.p_end IS NOT NULL;
			
		/*
		-- 2. insert 2UniProts
		*/
		INSERT IGNORE INTO 2UniProts (uid, vid, p_ref, p_mut, ft_id, uniprot, res_num, uniprot_res, annotation, des) 
		SELECT DISTINCT e.uid, e.id, e.p_ref, e.p_mut, f.id, p2u.uniprot, p2u.uniprot_res_num, p2u.uniprot_res, fc.val, ft.val
		FROM V2Ensembls e 
		JOIN SAMUL.Ensp2UniProt p2u ON p2u.ensp=e.ensp AND p2u.ensp_res_num BETWEEN e.p_start AND e.p_end 
		JOIN UNIPROT.feature f ON p2u.uniprot=f.acc 
		LEFT JOIN UNIPROT.featureVariant fv ON f.featureVariant=fv.id
		LEFT JOIN UNIPROT.featureClass fc ON f.featureClass=fc.id 
		-- AND (fc.val!= 'CHAIN' AND fc.val!='DOMAIN' AND fc.val!='STRAND' AND fc.val!='HELIX' AND fc.val!='TURN' AND fc.val!='REPEAT' AND fc.val!='COMPBIAS' 
		-- AND fc.val!='COILED' AND fc.val!='INIT_MET' AND fc.val!='NON_CONS' AND fc.val!='UNSURE')
		LEFT JOIN UNIPROT.featureType ft ON f.featureType=ft.id
		WHERE e.id=new.id
		and (fc.val!= 'CHAIN' AND fc.val!='DOMAIN' AND fc.val!='STRAND' AND fc.val!='HELIX' AND fc.val!='TURN' AND fc.val!='REPEAT' AND fc.val!='COMPBIAS' 
		AND fc.val!='COILED' AND fc.val!='INIT_MET' AND fc.val!='NON_CONS' AND fc.val!='UNSURE')
		AND IF(fc.val='DISULFID' OR fc.val='CROSSLNK', p2u.uniprot_res_num=f.start OR p2u.uniprot_res_num=f.end, p2u.uniprot_res_num BETWEEN f.start AND f.end)
		-- check allele type if the feature is 'VARIANT'
		AND IF(f.featureVariant IS NOT NULL, ((e.p_ref=fv.ori AND e.p_mut=fv.vari) OR (e.p_ref=fv.vari AND e.p_mut=fv.ori)), 1);
		
		/*
		-- 3. get HUMSAVAR from SwissVariants 
		*/
		INSERT IGNORE INTO 2UniProts (uid, vid, p_ref, p_mut, ft_id, uniprot, res_num, uniprot_res, annotation, des) 
		SELECT DISTINCT e.uid, e.id, e.p_ref, e.p_mut, sv.id, p2u.uniprot, p2u.uniprot_res_num, p2u.uniprot_res,
		'HUMSAVAR', IF(sv.type='Disease', CONCAT_WS(', mim: ', CONCAT_WS(', ', CONCAT_WS(': ', sv.variant_id, sv.type), sv.disease_name), sv.mim), CONCAT_WS(': ', sv.variant_id, sv.type))
		FROM V2Ensembls e
		JOIN SAMUL.Ensp2UniProt p2u ON p2u.ensp=e.ensp AND p2u.ensp_res_num BETWEEN e.p_start AND e.p_end
		JOIN UNIPROT.SwissVariants sv ON sv.sp_acc=p2u.uniprot AND sv.res_num=p2u.uniprot_res_num
		WHERE e.id=new.id
		AND ((sv.aa_original=e.p_ref AND sv.aa_variation=e.p_mut) OR (sv.aa_original=e.p_mut AND sv.aa_variation=e.p_ref));
		
		/*
		-- update substitution scores from BLOSUM and PAM (based on 2UniProts)
		-- this break the trigger, so move to SQL/update_2UniProts.sql via cron-tab
		UPDATE 2UniProts p 
		JOIN V2Ensembls e on p.vid=e.id -- and e.p_ref regexp '[ABCDEFGHIJKLMNPQRSTVWXYZ\*]' and e.mut regex '[ABCDEFGHIJKLMNPQRSTVWXYZ\*]'
		JOIN ESST.SubMat m1 on m1.aa1=e.p_ref and m1.aa2=e.p_mut and m1.matrix='BLOSUM62' 
		JOIN ESST.SubMat m2 on m2.aa1=e.p_ref and m2.aa2=e.p_mut and m2.matrix='PAM70'
		SET p.blosum62=m1.lor, p.pam70=m2.lor
		WHERE e.id=new.id ;
		*/
    END */;;

DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@SAVE_SQL_MODE*/;

--
-- Table structure for table `V2Families`
--

DROP TABLE IF EXISTS `V2Families`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `V2Families` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `vid` int(11) unsigned NOT NULL,
  `mem_id` int(7) unsigned NOT NULL,
  `fam_id` int(5) unsigned NOT NULL,
  `aln_pos` int(7) unsigned NOT NULL,
  `res_num` int(7) unsigned default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `v2fam` (`vid`,`fam_id`,`aln_pos`),
  KEY `vid` (`vid`),
  KEY `mem_id` (`mem_id`),
  KEY `fam_id` (`fam_id`,`aln_pos`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `V2Freqs`
--

DROP TABLE IF EXISTS `V2Freqs`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `V2Freqs` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `uid` int(11) unsigned NOT NULL,
  `rs_id` varchar(50) NOT NULL,
  `allele` mediumtext,
  `frequency` float unsigned default NULL,
  `count` int(11) unsigned default NULL,
  `pop_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `uid` (`uid`,`rs_id`,`allele`(280),`pop_id`),
  KEY `uid_2` (`uid`),
  KEY `rs_id` (`rs_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `V2Phens`
--

DROP TABLE IF EXISTS `V2Phens`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `V2Phens` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `uid` int(11) unsigned NOT NULL,
  `rs_id` varchar(50) NOT NULL,
  `des` varchar(255) default NULL,
  `ex_ref` varchar(255) default NULL,
  `p_value` double default NULL,
  `risk_allele` varchar(255) default NULL,
  `source` varchar(255) default NULL,
  `study` varchar(255) default NULL,
  `study_type` set('GWAS') default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `uid` (`uid`,`rs_id`,`des`),
  KEY `uid_2` (`uid`),
  KEY `rs_id` (`rs_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `V2dbNSFP`
--

DROP TABLE IF EXISTS `V2dbNSFP`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `V2dbNSFP` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `uid` int(11) unsigned NOT NULL,
  `nsfp_id` int(11) unsigned NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `uid` (`uid`),
  KEY `nsfp_id` (`nsfp_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `V2dbSNPs`
--

DROP TABLE IF EXISTS `V2dbSNPs`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `V2dbSNPs` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `uid` int(11) unsigned NOT NULL,
  `rs_id` varchar(50) NOT NULL,
  `allele_string` mediumtext,
  `ambi_code` char(1) default NULL,
  `minor_allele` char(1) default NULL,
  `ancestral_allele` varchar(255) default NULL,
  `mac` int(10) unsigned default NULL,
  `maf` float default NULL,
  `validation` tinytext,
  `clinical_significance` varchar(500) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `uid` (`uid`,`rs_id`),
  KEY `uid_2` (`uid`),
  KEY `rs_id` (`rs_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `_ClassifiedDiseases`
--

DROP TABLE IF EXISTS `_ClassifiedDiseases`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `_ClassifiedDiseases` (
  `id` int(5) unsigned NOT NULL auto_increment,
  `diag_code` varchar(50) NOT NULL,
  `which_level` enum('a','b','c','d') NOT NULL,
  `category` char(2) NOT NULL,
  `is_novel` int(1) NOT NULL,
  `cnt_unique_call` int(5) NOT NULL,
  `cnt_call` int(5) NOT NULL,
  `cnt_unique_sample` int(5) NOT NULL,
  `cnt_unique_bru` int(5) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `diag_code` (`diag_code`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `_ClassifiedGeneDiseases`
--

DROP TABLE IF EXISTS `_ClassifiedGeneDiseases`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `_ClassifiedGeneDiseases` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `hgnc` varchar(50) default NULL,
  `diag_code` varchar(20) NOT NULL,
  `which_level` enum('a','b','c','d') NOT NULL,
  `category` char(2) NOT NULL,
  `is_novel` int(1) NOT NULL,
  `cnt_unique_call` int(5) NOT NULL,
  `cnt_call` int(5) NOT NULL,
  `cnt_unique_sample` int(5) NOT NULL,
  `cnt_unique_bru` int(5) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `hgnc` (`hgnc`,`diag_code`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `_ClassifiedGenePatients`
--

DROP TABLE IF EXISTS `_ClassifiedGenePatients`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `_ClassifiedGenePatients` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `hgnc` varchar(50) default NULL,
  `bru_code` char(9) NOT NULL,
  `which_level` enum('a','b','c','d') NOT NULL,
  `category` char(2) NOT NULL,
  `is_novel` int(1) NOT NULL,
  `cnt_unique_call` int(5) NOT NULL,
  `cnt_call` int(5) NOT NULL,
  `cnt_unique_sample` int(5) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `hgnc` (`hgnc`,`bru_code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `_ClassifiedPatients`
--

DROP TABLE IF EXISTS `_ClassifiedPatients`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `_ClassifiedPatients` (
  `id` int(5) unsigned NOT NULL auto_increment,
  `bru_code` char(9) NOT NULL,
  `which_level` enum('a','b','c','d') NOT NULL,
  `category` char(2) NOT NULL,
  `is_novel` int(1) NOT NULL,
  `cnt_unique_call` int(5) NOT NULL,
  `cnt_call` int(5) NOT NULL,
  `cnt_unique_sample` int(5) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `bru_code` (`bru_code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `_ClassifiedSamples`
--

DROP TABLE IF EXISTS `_ClassifiedSamples`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `_ClassifiedSamples` (
  `id` int(5) unsigned NOT NULL auto_increment,
  `sample_id` int(10) unsigned NOT NULL,
  `which_level` enum('a','b','c','d') NOT NULL,
  `category` char(2) NOT NULL,
  `is_novel` int(1) NOT NULL,
  `cnt_unique_call` int(5) NOT NULL,
  `cnt_call` int(5) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `sample_id` (`sample_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `_ClassifiedTargetDiseases`
--

DROP TABLE IF EXISTS `_ClassifiedTargetDiseases`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `_ClassifiedTargetDiseases` (
  `id` int(5) unsigned NOT NULL auto_increment,
  `target_name` varchar(100) NOT NULL,
  `diag_code` varchar(20) NOT NULL,
  `which_level` enum('a','b','c','d') NOT NULL,
  `category` char(2) NOT NULL,
  `is_novel` int(1) NOT NULL,
  `cnt_unique_call` int(5) NOT NULL,
  `cnt_call` int(5) NOT NULL,
  `cnt_unique_sample` int(5) NOT NULL,
  `cnt_unique_bru` int(5) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `target_name` (`target_name`,`diag_code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `_ClassifiedTargets`
--

DROP TABLE IF EXISTS `_ClassifiedTargets`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `_ClassifiedTargets` (
  `id` int(5) unsigned NOT NULL auto_increment,
  `target_name` varchar(100) NOT NULL,
  `which_level` enum('a','b','c','d') NOT NULL,
  `category` char(2) NOT NULL,
  `is_novel` int(1) NOT NULL,
  `cnt_unique_call` int(5) NOT NULL,
  `cnt_call` int(5) NOT NULL,
  `cnt_unique_sample` int(5) NOT NULL,
  `cnt_unique_bru` int(5) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `target_name` (`target_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `_MetaCalls`
--

DROP TABLE IF EXISTS `_MetaCalls`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `_MetaCalls` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `sample_id` int(5) unsigned NOT NULL,
  `uid` int(11) unsigned NOT NULL,
  `dibayes` int(11) unsigned default NULL,
  `dp_dibayes` int(11) unsigned default NULL,
  `smallindel` int(11) unsigned default NULL,
  `gatk` int(11) unsigned default NULL,
  `dp_gatk` int(11) unsigned default NULL,
  `gatk_ug` int(11) unsigned default NULL,
  `dp_gatk_ug` int(11) unsigned default NULL,
  `gatk_hc` int(11) unsigned default NULL,
  `dp_gatk_hc` int(11) unsigned default NULL,
  `samtool` int(11) unsigned default NULL,
  `dp_samtool` int(11) unsigned default NULL,
  `cg` int(11) unsigned default NULL,
  `dp_cg` int(11) unsigned default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `sample_var` (`sample_id`,`uid`),
  KEY `sample_id` (`sample_id`),
  KEY `uid` (`uid`),
  KEY `dibayes` (`dibayes`),
  KEY `gatk` (`gatk`),
  KEY `samtool` (`samtool`),
  KEY `gatk_hc` (`gatk_hc`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `_UnifiedCalls`
--

DROP TABLE IF EXISTS `_UnifiedCalls`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `_UnifiedCalls` (
  `id` int(11) NOT NULL auto_increment,
  `chr` varchar(5) NOT NULL,
  `v_start` int(11) NOT NULL,
  `v_end` int(11) NOT NULL,
  `reference` varchar(1000) NOT NULL,
  `genotype` varchar(1000) NOT NULL,
  `in_ensembl` int(1) NOT NULL default '0',
  `has_found` int(1) NOT NULL default '0',
  `is_new` int(1) NOT NULL default '1',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `chr_2` (`chr`,`v_start`,`v_end`,`reference`(160),`genotype`(160)),
  KEY `chr` (`chr`),
  KEY `in_ensembl` (`in_ensembl`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

/*!50003 SET @SAVE_SQL_MODE=@@SQL_MODE*/;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`sung`@`%` */ /*!50003 TRIGGER `insert_isnovels_after_unifiedcalls` AFTER INSERT ON `_UnifiedCalls` FOR EACH ROW BEGIN
		-- deprecated 
		-- use 'HasFound' instead
		/*
		-- INSERT IGNORE INTO IsNovels (uid, acc_num, tag,rs_id, mut_id)
		replace INTO IsNovels (uid, acc_num, tag,rs_id, mut_id)
		SELECT u.id, h.acc_num, h.tag, s.rs_id, ir.mut_id
		FROM _UnifiedCalls u 
		-- LEFT JOIN CleanedHGMDs h ON u.`chr` = h.chr AND u.`v_start` = h.g_start AND u.`v_end` = h.g_end and u.`reference` = h.reference and u.`genotype` = h.genotype
		LEFT JOIN CleanedHGMDs h ON u.`chr` = h.chr AND u.`v_start` = h.g_start AND u.`v_end` = h.g_end AND u.`reference` = IF(is_same_ref=0, genotype, reference) AND u.`genotype` = IF(is_same_ref=0, reference, genotype)
		LEFT JOIN V2dbSNPs s ON u.id=s.uid
		-- LEFT JOIN ICCRefs ir ON u.chr=ir.chr AND u.v_start=ir.`g_start` AND u.v_end=ir.`g_end` AND ir.is_same_coord!=0
		LEFT JOIN ICCRefs ir ON u.chr=ir.chr AND u.v_start=ir.`g_start` AND u.v_end=ir.`g_end` AND u.`reference`=ir.`reference` AND u.`genotype`=ir.`genotype` AND ir.is_same_coord=1 AND ir.is_same_ref=1 AND ir.is_coord_from_icc!=1
		
		WHERE u.id=new.id;
		*/
    END */;;

DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@SAVE_SQL_MODE*/;

--
-- Table structure for table `diBayes`
--

DROP TABLE IF EXISTS `diBayes`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `diBayes` (
  `id` int(11) NOT NULL auto_increment,
  `sample_id` int(11) NOT NULL,
  `variant_type` varchar(50) NOT NULL,
  `chr` varchar(50) NOT NULL,
  `v_start` int(11) NOT NULL,
  `v_end` int(11) NOT NULL,
  `reference` varchar(255) NOT NULL,
  `genotype` varchar(255) NOT NULL,
  `score` float(8,6) NOT NULL,
  `coverage` int(5) NOT NULL,
  `ref_allele_counts` int(5) NOT NULL,
  `ref_allele_starts` int(5) NOT NULL,
  `ref_allele_meanQV` int(5) NOT NULL,
  `novel_allele_counts` int(5) NOT NULL,
  `novel_allele_starts` int(5) NOT NULL,
  `novel_allele_meanQV` int(5) NOT NULL,
  `maad2` int(5) NOT NULL,
  `saad3` int(5) NOT NULL,
  `het` int(1) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `sample_id` (`sample_id`,`chr`,`v_start`,`v_end`,`reference`(100),`genotype`(100)),
  KEY `chr` (`chr`,`v_start`,`v_end`,`reference`(100),`genotype`(100)),
  KEY `sample_id_2` (`sample_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

/*!50003 SET @SAVE_SQL_MODE=@@SQL_MODE*/;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`sung`@`%` */ /*!50003 TRIGGER `insert_unifiedcalls_after_dibayes` AFTER INSERT ON `diBayes` FOR EACH ROW BEGIN
		INSERT ignore INTO _UnifiedCalls
		set chr=new.chr, v_start=new.v_start, v_end=new.v_end, reference=new.reference, genotype=new.genotype;
		/*
		update _UnifiedCalls
		join V2Ensembls v on new.chr=v.chr and new.v_start=v.g_start and new.v_end=v.g_end and new.reference=v.reference and new.genotype=v.genotype
		set u.in_ensembl=1;
		*/
    END */;;

DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@SAVE_SQL_MODE*/;

--
-- Final view structure for view `TargetGenes`
--

/*!50001 DROP TABLE `TargetGenes`*/;
/*!50001 DROP VIEW IF EXISTS `TargetGenes`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`sung`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `TargetGenes` AS (select `TargetRegions`.`id` AS `id`,`TargetRegions`.`target_id` AS `target_id`,`TargetRegions`.`hgnc` AS `hgnc`,`TargetRegions`.`ensg` AS `ensg` from `TargetRegions` group by `TargetRegions`.`target_id`,`TargetRegions`.`hgnc`,`TargetRegions`.`ensg`) */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-02-09  1:00:04
