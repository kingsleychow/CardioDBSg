#!/usr/bin/perl -w 
#===============================================================================
#
#         FILE:  make_Samples.pl
#
#        USAGE:  ./make_Samples.pl  
#
#  DESCRIPTION:  making Samples.txt to dump into mysql
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Chow Kingsley, kingsley.chow@nhcs.com.sg
#      COMPANY:  National Heart Research Institute Singapore, NHCS
#      VERSION:  1.0
#      CREATED:  10/30/2012 11:58:00 AM
#     REVISION:  ---
#===============================================================================

use strict;
use Getopt::Long;

#my $local_cg_dir='/backups/master/data/results/CompleteGenomics';
#die "cannot find local complete genomic dir: $local_cg_dir\n" unless -d $local_cg_dir;
my $my_db='cardiodbs_test';
my $my_db_con='-h 127.0.0.1 -P 3308 -uroot -proot';

my ($allcg, @run, $help, $debug, $miseq_target, $miseq_pool);
GetOptions
(
    'allcg!'	=>	\$allcg, #flag
	'run_name=s' => \@run, #array
	'help!' => \$help,
	'debug!' => \$debug,
	'target=s' => \$miseq_target,
	'pool=s' => \$miseq_pool,
);

sub usage{
	die "\e[32m[USAGE] --run_name [run1,run2] --allcg [a flag for CG only] --target [only for MiSeq run]
	[Examples]
	perl $0 --allcg
		: to make all CG sample lists from all local Complete Genomics data 
	perl $0 --run_name CG-009E8,CG-009E9 (separated by ',' witouht any space in between)
		: for selected run(s) 
	perl $0 --run_name CMR000070_20130219_DCMreto_ARVC
		: a single run
	perl $0 --run_name  130613_M01389_0016_000000000-A4TDC --target ICC_177Genes_DiagPanel --pool XT2_177gene
		: a single MiSeq run
	\e[0m\n";
}

&usage and exit if $help;

@run= split(/,/,join(',',@run));

my $list;

MAIN:{
	for my $run_name(@run){
		warn "run=$run_name\n" if $debug;
		my $platform=`mysql $my_db_con $my_db --skip-column-names -e "select platform from Runs where run_name='$run_name'" `; chomp $platform;
		if ($platform eq 'CG'){
			&make_cg_sample($run_name);
		}elsif($platform eq '5500xl'){
			&make_solid_sample($run_name);
		}elsif($platform eq 'MiSeq'){
			die "[required] --target [TARGET_NAME]\n" unless $miseq_target;
			die "[required] --pool [POOL_NAME]\n" unless $miseq_pool;
			&make_miseq_sample_wt_code($run_name);
		}else{
			warn "The platform $platform not avaiable for this scirpt or not in Runs table?\nMake it by your own\n";
			&usage and exit;
		}
	}
}

=not_using_solid_platform

sub make_solid_sample{
	my $run_name=shift;
	my $run_def_top='/data/Store/RunDef/5500xl';

	my $run_id=`mysql $my_db --skip-column-names -e "select id from Runs where run_name='$run_name'" `; chomp $run_id;
	die "No such a run $run_name in $my_db\n" unless $run_id; 

	#/data/Store/RunDef/5500xl/CMR000070_20130219_DCMreto_ARVC
	#/data/Store/RunDef/5500xl/CMR000070_20130121_dcmTOPUP_1
	my $run_def_dir=$run_def_top.'/'.$run_name;
	die "cannot find run_def $run_def_dir\n" unless -d $run_def_dir;
	foreach my $pool_name (split(/\s+/, `ls $run_def_dir`)){
		chomp $pool_name; 
		#/data/Store/RunDef/5500xl/CMR000070_20130121_dcmTOPUP_1/DCMD_Pool1_SO358382_TopUp_408151
		#/data/Store/RunDef/5500xl/CMR000070_20130418_HVOLA_MVP/HVOLA2_BAV_35616
		my $pool_dir=$run_def_dir.'/'.$pool_name;
		die "cannot find pool_dir $pool_dir\n" unless -d $pool_dir;
		foreach my $file (split(/\s+/, `ls $pool_dir`)){
			chomp $file;
			if($file=~/^group_(\S+).txt$/){
				my $run_def_file=$pool_dir.'/'.$file;
				#/data/Store/RunDef/5500xl/CMR000070_20130219_DCMreto_ARVC/DCM_retro_ARVC_S0411142/group_ICCv6.txt
				#/data/Store/RunDef/5500xl/CMR000070_20130121_dcmTOPUP_1/DCMA_Pool2_SO358382_TopUp_408151/group_ICCv4.TopUp_408151.txt
				my $target_name=$1;
				print "\t$run_def_file (target:$target_name)\n" if $debug;
				die "cannot find run_def_file:$run_def_file\n" unless -s $run_def_file;

				my %unique_samples; #key: sample_name value: bar_code
				open(DEF, $run_def_file) or warn "$!\n";
				while(<DEF>){
					#20CS01710   /data/results/5500xl/reads/CMR000070_20130219_DCMreto_ARVC_01.xsq:2
					my @dummy=split(/\s+/);
					my @dummy2=split(':',$dummy[1]);
					$unique_samples{$dummy[0]}=$dummy2[1];
				}
				close DEF;
				foreach my $sample_name (sort {$unique_samples{$a}<=>$unique_samples{$b}} keys %unique_samples){
					my ($bru_code,$g_code,$diag_code,$target_id)=&get_diag_target($sample_name,$target_name);
					$diag_code='\N' if $diag_code=~/NULL/;
					$pool_name=~s/_$target_id//;
					print "0\t$run_id\t$run_name\t$pool_name\t$sample_name\t$bru_code\t$g_code\t$target_id\t$diag_code\t$unique_samples{$sample_name}\t\\N\n";
				}
			}#end of if $file
		}#end of foreach $file
	}#end of foreach $pool
}
=cut

sub get_diag_target{
	my ($sample_name,$target_name)=@_;

	my $sample_code=substr($sample_name, 0, 9);
	my ($bru_code,$g_code,$diag_code);
	# 13G000022
	if($sample_code=~/^\d{2}G\d{6}$/){ 
		$g_code=$sample_code;
		$bru_code='\N'; # NULL
		$diag_code='DIAG'
	# 10MG00682, 20AB00111
	}else{
		$g_code='\N';
		$bru_code=$sample_code;
		my $my_table=$sample_name=~/^20/? 'GeneticsRecords':'PatPatients';
e		$diag_code= `mysql $my_db_con $my_db --skip-column-names -e "select c_diag_code from $my_table where bru_code='$bru_code'"`; chomp $diag_code;
		if($diag_code=~/NULL/){
			$diag_code=`mysql $my_db_con $my_db --skip-column-names -e "select q_diag_code from $my_table where bru_code='$bru_code'"`; 
			chomp $diag_code;
		}

	}

	my $target_id=`mysql $my_db_con $my_db --skip-column-names -e "select target_id from Targets where target_name='$target_name'"`; chomp $target_id;
	die "No target_id for $target_name \n" unless $target_id;

	return ($bru_code,$g_code,$diag_code,$target_id);
}

sub make_miseq_sample{
	my $run_name=shift;
	#my $miseq_top='/MiSeq/Illumina/MiSeqAnalysis';
	my $miseq_top='/data1/seq_data/NHCS/MiSeq';
	#/MiSeq/Illumina/MiSeqAnalysis/130321_M01389_0008_000000000-A3D3D/SampleSheet.csv
	#/data/results/MiSeq/130531_M01389_0014_000000000-A3F2A/SampleSheet.csv
	die "cannot find $miseq_top\n" unless -d $miseq_top;
	my $sample_file=$miseq_top.'/'.$run_name.'/SampleSheet.csv';
	die "no such a file: $sample_file\n" unless -s $sample_file;

	my $run_id=`mysql $my_db_con $my_db --skip-column-names -e "select id from Runs where run_name='$run_name'" `; chomp $run_id;
	die "No such a run $run_name in $my_db\n" unless $run_id; 

	open(DEF, $sample_file) or warn "$!\n";

=format
	[Data]
	Sample_ID,Sample_Name,Sample_Plate,Sample_Well,I7_Index_ID,index,Sample_Project,Description
	20BA02862,,,,A001,ATCACG,,
	20CD02891,,,,A002,CGATGT,,
	20DP02929,,,,A003,TTAGGC,,
	20AH02843,,,,A004,TGACCA,,
=cut
	$/="[";
	my($sample_name,$tag,$barcode);
	while(<DEF>){
		if(/Data]/){
			foreach my $line (split('\n')){
				warn $line,"\n\n" if $debug;
				my @ele=split(',',$line);
				if(scalar @ele =>8){
					$sample_name=$ele[0];
					#$tag='S'.substr($ele[4],3,1);
					$tag=$ele[4]; # 10ET00007,10ET00007,dcm,,FLD0097,TGCTACATCA,,,,,,,
					$barcode=$ele[5];
					if(defined $sample_name and $sample_name=~/^\d{2}\D/){
						my ($bru_code,$g_code,$diag_code,$target_id)=&get_diag_target($sample_name,$miseq_target);
						$diag_code='\NN' if $diag_code=~/NULL/;
						# this is because $/ was set to "["
						chop $diag_code if $g_code eq '\N'; # bru_code only 
						chop $target_id; 
						print "0\t$run_id\t$run_name\t$miseq_pool\t$sample_name\t$bru_code\t$g_code\t$target_id\t$diag_code\t$tag\t$barcode\n";
					}
				}
			}
		}
	}	
	close DEF;
}


sub make_miseq_sample_wt_code{
	my $run_name=shift;
	my $miseq_top='/data1/seq_data/NHCS/MiSeq';
	die "cannot find $miseq_top\n" unless -d $miseq_top;
	my $sample_file=$miseq_top.'/'.$run_name.'/SampleSheet.csv';
	die "no such a file: $sample_file\n" unless -s $sample_file;
        
	my $run_id=`mysql $my_db_con $my_db --skip-column-names -e "select id from Runs where run_name='$run_name'" `; chomp $run_id;
	die "No such a run $run_name in $my_db\n" unless $run_id;
        
	open(DEF, $sample_file) or warn "$!\n";
        
	$/="[";
	my($sample_name,$tag,$barcode);
	while(<DEF>){
		if(/Data]/){
			foreach my $line (split('\n')){
				warn $line,"\n\n" if $debug;
				my @ele=split(',',$line);
				if(scalar @ele =>8){
					$sample_name=$ele[0];
					$tag=$ele[4];
					$barcode=$ele[5];
					my $target_id=`mysql $my_db_con $my_db --skip-column-names -e "select target_id from Targets where target_name='$miseq_target'"`; chomp $target_id;
					die "No target_id for $miseq_target \n" unless $target_id;
					chop $target_id;
					print "0\t$run_id\t$run_name\t$miseq_pool\t$sample_name\tNA\tNA\t$target_id\tNA\t$tag\t$barcode\n";
				}
			}
		}
	}
	close DEF;
}


=not_using_cg_platform
sub make_cg_sample{
	my $run_name=shift;
	my $list;
	if ($allcg){
		$list=`ls -ltr $local_cg_dir -R | grep -P 'DNA_\\S{3}:' | sed 's/://'g`
	}else{
		$list.=`ls -ltr $local_cg_dir/$run_name -R | grep -P 'DNA_\\S{3}:' | sed 's/://'g`
	}

	foreach my $entry(split('\n',$list)){
		#/backups/master/data/results/CompleteGenomics/CG-009E8/GS000017382-DID/GS000014075-ASM/GS01281-DNA_E04
		my @tmp=split('/',$entry);
		my ($run_name,$pool_name,$bar_code,$cg_sample_name)=($tmp[6],$tmp[7],$tmp[8],$tmp[9]);

		#get run id 
		my $run_id=`mysql $my_db --skip-column-names -e "select id from Runs where run_name='$tmp[6]'" `;
		chomp $run_id;

		#get bru_code 
		my $bru_code=`mysql $my_db --skip-column-names -e "select bru_code from CGSamples where cg_sample_name='$cg_sample_name'" `;
		chomp $bru_code;

		# get diag code
		my $my_table=$bru_code=~/^20/? 'GeneticsRecords':'PatPatients';
		my $diag_code=`mysql $my_db --skip-column-names -e "select c_diag_code from $my_table where bru_code='$bru_code'"`;
		chomp $diag_code;
		$diag_code= `mysql $my_db --skip-column-names -e "select q_diag_code from $my_table where bru_code='$bru_code'"` if $diag_code eq 'NULL' ;
		chomp $diag_code;

		print "0\t$run_id\t$run_name\t$pool_name\t$bru_code\t$bru_code\\N\tWG\t$diag_code\t$bar_code\t$cg_sample_name\n";
	}
}
=cut
