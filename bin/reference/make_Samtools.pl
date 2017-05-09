#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use DBI;

my $db='';
my $dbhost='';
my $dbport='';
my $dbuser='';
my $dbpass='';
my $type='SQL';
my $DEBUG;  
my $run_name='';
my ($pool_name,$sample_name);

GetOptions
(
  'debug!'              =>      \$DEBUG,
  'run_name=s'          =>      \$run_name,
  'db=s'                =>      \$db,
  'dbhost=s'            =>      \$dbhost,
  'dbport=s'            =>      \$dbport,
  'dbuser=s'            =>      \$dbuser,
  'dbpass=s'            =>      \$dbpass,
  'pool_name:s'         =>      \$pool_name, #optional
  'sample_name:s'       =>      \$sample_name, #optional
) or &usage();

warn "\e[33mrequired argument value for --run_name\e[0m\n" and &usage() unless $run_name;

#my $solid_root="/data/results/s0464.pssc";
#my $fff_root="/data/results/454";
#my $hiseq_root='/data/results/HiSeq';
my $miseq_root='/data1/seq_data/NHCS/MiSeq/results';
#my $xl_root='/data/results/5500xl/projects/lifescope';

MAIN: {
	
	my $dbh = DBI->connect("DBI:mysql:database=$db;host=$dbhost;port=$dbport","$dbuser","$dbpass")
                or die "Couldn't connect to database: " . DBI->errstr;
        my $sql;
        my @sql_out;
        if($run_name eq 'all'){
                $sql=$dbh->prepare("SELECT s.id,s.run_name,s.pool_name,s.sample_name,s.target_id,r.machine FROM Samples s JOIN Runs r ON s.run_id=r.id")
                        or die "Couldn't prepare statement: " . $dbh->errstr;
                $sql->execute()
                        or die "Couldn't execute statement: " . $sql->errstr;
        }else{
                my $aux=$pool_name? "and pool_name='$pool_name' ":'';
                $aux=$sample_name? $aux."and sample_name='$sample_name'":$aux;

                $sql=$dbh->prepare("SELECT s.id,s.run_name,s.pool_name,s.sample_name,s.target_id,r.machine FROM Samples s JOIN Runs r ON s.run_id=r.id where s.run_name= ? $aux order by s.id")
                        or die "Couldn't prepare statement: " . $dbh->errstr;
                $sql->execute($run_name)
                        or die "Couldn't execute statement: " . $sql->errstr;
	}
	die "No entries in $db.Samples\n" unless defined $sql;

	while (@sql_out = $sql->fetchrow_array()){
		my ($sample_id,$run_name,$pool_name,$sample_name,$target_id,$machine)=@sql_out;
		my $sam_flt;
		if($machine eq 'HiSeq'){
#			my $pool_dir=$hiseq_root.'/'.$run_name.'/'.$pool_name;
#			$pool_dir=$hiseq_root.'/'.$run_name.'/'.$pool_name.'_'.$target_id if -d $hiseq_root.'/'.$run_name.'/'.$pool_name.'_'.$target_id;

			# /data/results/HiSeq/120803_SN674_0189_BD12RKACXX_JamesWare/Lane2/BWA_gatk_snp_indel_AdapterTrimmed/20aa00254/Bait/20aa00254_GTGAGAGACA.Realigned.recalibrated.OnBait.q8.bam.samtools.flt.vcf
#			$sam_flt="$pool_dir/gatk_snp_indel_AdapterTrimmed/$sample_name/Bait/$sample_name.Realigned.recalibrated.OnBait.q8.bam.samtools.flt.vcf";
			
			#/data/results/HiSeq/130118_SN674_0199_AC13LGACXX/MYRN_SureSelect/BWA_gatk_snp_indel/20AA02416/Target/20AA02416_AGTCACTA.markDup.Realigned.recalibrated.OnTarget.q8.bam.samtools.flt.vcf
#			$sam_flt="$pool_dir/gatk_snp_indel/$sample_name/Target/$sample_name.markDup.Realigned.recalibrated.OnTarget.q8.bam.samtools.flt.vcf" unless -s $sam_flt;
		}elsif($machine eq 'MiSeq'){
			my $pool_dir=$miseq_root.'/'.$run_name.'/'.$pool_name;
			$pool_dir=$miseq_root.'/'.$run_name.'/'.$pool_name.'_'.$target_id if -d $miseq_root.'/'.$run_name.'/'.$pool_name.'_'.$target_id;
			#/data/results/MiSeq/130531_M01389_0014_000000000-A3F2A/PRDM16_Fluidigm/BWA_gatk_snp_indel/14EG01498a/Target/14EG01498a.Realigned.recalibrated.OnTarget.q8.bam.samtools.flt.vcf
			$sam_flt="$pool_dir/gatk_snp_indel/$sample_name/Target/$sample_name.markDup.Realigned.recalibrated.OnTarget.q8.bam.samtools.flt.vcf";
			$sam_flt="$pool_dir/gatk_snp_indel/$sample_name/Target/$sample_name.Realigned.recalibrated.OnTarget.q8.bam.samtools.flt.vcf" unless -s $sam_flt;
                        $sam_flt="$pool_dir/gatk_snp_indel/$sample_name/Target/$sample_name.markDup.Realigned.recalibrated.OnTarget.q15.bam.samtools.flt.vcf" unless -s $sam_flt;
		}else{
			warn "\e[031mSamtools only for Soid4, 454, or 5500XL\e[0m\n" and next;
		}

		warn "\e[32mcannot find $sam_flt (maybe not run yet?)\e[0m\n" and next unless -s $sam_flt;

		&parse_vcf($sample_id,$sam_flt);
	}#end of @samples

	$sql->finish();
	$dbh->disconnect();

}#end of MAIN

sub parse_vcf{
	my ($sample_id, $file)=@_;
	# now parse snp results
	#CHROM  POS ID  REF ALT QUAL    FILTER  INFO    FORMAT  LIBR1   
	#chr1    63527   .   T   C   85.5    .   DP=4;AF1=1;CI95=0.5,1;DP4=0,0,4,0;MQ=40;FQ=-39  GT:PL:GQ    1/1:118,12,0:72
	#chr1    1900106 .   TCT TCTCCT  51.5    .   INDEL;DP=20;AF1=0.5;CI95=0.5,0.5;DP4=11,0,5,0;MQ=44;FQ=54.5;PV4=1,1,0.02,1  GT:PL:GQ    0/1:89,0,214:92
	print "\e[32mparsing $file\e[0m\n" if $DEBUG;
	open (VAR, "<$file") or die "cannotp open $file:$!\n"; 
	while(<VAR>){
		chomp;
		next if $_=~/^#/;
		my ($chr,$g_start,$known,$reference,$genotype,$qual,$filter,$info,$format,$data)=split(/\t/,$_);
		$filter='\\N' if $filter eq '.';
		$qual = '\\N' if $qual eq '.';
		$known = '\\N' if $known eq '.';

		my$is_snp= $info=~/INDEL/ ? 0:1;

		## info ##
		$info=~s/INDEL;//g; $info=~s/DB;//g; $info=~s/DS;//g; # No value assinged (e.g. DB;DS;
		my @dummy=split(/;/,$info);
		my %att= map split(/=/), @dummy; #crash unless $_ contains '='

		my $af=exists $att{AF1}? $att{AF1}:'\\N'; # $att{AF} could be undef 
		my $t_dp=exists $att{DP}? $att{DP}:'\\N'; # $att{DP} could be undef 
		my $mq=exists $att{MQ}? $att{MQ}:'\\N'; 

		# GT:PL:GQ 
		my @format=split(/:/,$format);
		# 0/1:89,0,214:92
		my @data=split(/:/,$data);

		my %data;
		for(my$i=0;$i<$#format+1;$i++){
			$data{$format[$i]}=$data[$i];
		}

		my $gt=exists $data{GT}? $data{GT}:'\\N'; # $data{GT} could be undef 
		my $pl=exists $data{PL}? $data{PL}:'\\N'; # $data{PL} could be undef 
		my $gq=exists $data{GQ}? $data{GQ}:'\\N'; # $data{DP} could be undef 

		# to cope with Ensembl API;
		my $snp_type;
		# SNP
		if($is_snp){
			$snp_type='SNP';
			foreach my $geno(split(/,/,$genotype)){
				#[QC] is the length same?
				if(length($reference)==length($geno)){
					print "0\t$sample_id\t$snp_type\t$chr\t$g_start\t$g_start\t$reference\t$geno\t$qual\t$filter\t$known\t$af\t$t_dp\t$mq\t$info\t$gt\t$pl\t$gq\n" unless $DEBUG;
				}else{
					die "\e[31mlength of $reference NOT same with $geno for SNP?\n$_\e[0m\n";
				}
			}
		# Indel
		}else{
			foreach my $geno(split(/,/,$genotype)){
				my ($ref,$mut,$start,$end); #formatted
				# to represent deletion for (ACGT/A) as (CGT/-) 
				# chr1    2938407 .   CAGAAGAAG   CAGAAG (AAG/-)
				# chr1    156280296   .   GATAAATAAATAAAT GATAAATAAAT (AAAT/-)
				if(length($reference) > length($geno)){
					$snp_type='Del';
					#[QC] is $genotype substring of $ref?
					if($geno eq substr($reference, 0, length($geno))){
						$start=$g_start + length($geno);
						$end=$g_start + length($reference) - 1;
						$ref=substr($reference, length($geno), length($reference)-length($geno));
						$mut='-';
					# chr10   88486102    .   CTAGCTTTCT  CAGCTTTCT   9.93
					# chr7    100550651       .       TCACCTCACACA    TNNNCACCTCACACA,TCA     93.5
					}else{
						warn "\e[31m$geno is not substring of $reference :\e[0m\n$_\n" and next;
					}
				# to represent insertion for (A/AAAG) as (-/AAG)
				# chr1    85331808    .   GAGAAG  GAGAAGAAG (-/AAG)
				}elsif(length($reference) < length($geno)){
					$snp_type='Ins';
					#[QC] is $ref substring of $geno?
					if($reference eq substr($geno, 0, length($reference))){
						$start=$g_start + length($reference);
						$end=$start - 1;
						$ref='-';
						$mut=substr($geno, length($reference), length($geno)-length($reference));
					}else{
						warn "\e[31m$reference is not substring of $geno :\e[0m\n$_\n" and next;
					}
				# chr1    78430689    .   AGAAG   AGGAAG,A
				}else{
					die "\e[31mlength of $reference same with $geno for Indel?\n$_\e[0m\n";
				}
				print "0\t$sample_id\t$snp_type\t$chr\t$start\t$end\t$ref\t$mut\t$qual\t$filter\t$known\t$af\t$t_dp\t$mq\t$info\t$gt\t$pl\t$gq\n" unless $DEBUG;
			}#end of foreach $genotype
		}# end of if is_snp
	}#end of while SNP
	close VAR;
}

sub usage{
	die "\e[32m[USAGE] perl $0 --run_name [run_name] --pool_name=[pool_name] --sample_name=[sample_name] --debug [optional to debug]\e[0m\n";
}
