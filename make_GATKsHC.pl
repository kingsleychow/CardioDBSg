#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use DBI;
use warnings;

my $db='';
#my $dbhost='';
#my $dbport='';
#my $dbuser='';
#my $dbpass='';
my $dbconfig='';
my $type='SQL'; #default
my $DEBUG;  
my $run_name='';
my $result_root='';
my $miseq_result_root='';
my $nextseq_result_root='';
my ($pool_name,$sample_name);

GetOptions
(
  'debug!'		  =>	\$DEBUG,
  'run_name=s'		  =>	\$run_name,
  'db=s'		  =>	\$db,
#  'dbhost=s'		  =>	\$dbhost,
#  'dbport=s'		  =>	\$dbport,
#  'dbuser=s'		  =>	\$dbuser,
#  'dbpass=s'		  =>	\$dbpass,
  'dbconfig=s'		  =>	\$dbconfig,
  'pool_name:s'		  =>	\$pool_name, #optional
  'sample_name:s'	  =>	\$sample_name, #optional
  'miseq_result_path=s'	  =>	\$miseq_result_root,
  'nextseq_result_path=s' =>    \$nextseq_result_root
) or &usage();

warn "\e[33mrequired argument value for --run_name\e[0m\n" and &usage() unless $run_name;

#my $solid_root="/data/results/s0464.pssc";
##my $fff_root="/data/results/454";
##my $hiseq_root='/data/results/HiSeq';
#my $miseq_root='/data1/seq_data/NHCS/MiSeq/results';
##my $xl_root='/data/results/5500xl/projects/lifescope';


MAIN: {
#       my %config = do '/other/CardioDBS/Devel/scripting/cardiodbs_perl.conf';
	my $dbh = DBI->connect("DBI:mysql:;mysql_read_default_file=$dbconfig",undef,undef)
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

		if ($sql->rows == 0) {
			die "\e[31mNo entries in $db.Samples\e[0m\n";
		}
	}
#	die "No entries in $db.Samples\n" unless $sql;

	while (@sql_out = $sql->fetchrow_array()){
		my ($sample_id,$run_name,$pool_name,$sample_name,$target_id,$machine)=@sql_out;
		my ($gatk_snp, $gatk_indel);
		if($machine eq 'HiSeq'){
#			$result_root='/data/results/HiSeq';
#			my $pool_dir=$result_root.'/'.$run_name.'/'.$pool_name;
#			$pool_dir=$result_root.'/'.$run_name.'/'.$pool_name.'_'.$target_id if -d $result_root.'/'.$run_name.'/'.$pool_name.'_'.$target_id;

			#/data/results/HiSeq/120803_SN674_0189_BD12RKACXX_JamesWare/Lane2/BWA_gatk_snp_indel_AdapterTrimmed/20aa00254/Bait/20aa00254_GTGAGAGACA.Realigned.recalibrated.OnBait.q8.bam.final.snp.vcf
#			$gatk_snp="$pool_dir/gatk_snp_indel_AdapterTrimmed/$sample_name/Bait/$sample_name.Realigned.recalibrated.OnBait.q8.bam.final.snp.vcf";

			#/data/results/HiSeq/130118_SN674_0199_AC13LGACXX/MYRN_SureSelect/BWA_gatk_snp_indel/20AA02416/Target/20AA02416_AGTCACTA.markDup.Realigned.recalibrated.OnTarget.q8.bam.final.snp.vcf
#			$gatk_snp="$pool_dir/gatk_snp_indel/$sample_name/Target/$sample_name.markDup.Realigned.recalibrated.OnTarget.q8.bam.final.snp.vcf" unless -s $gatk_snp;

			#/data/results/HiSeq/120803_SN674_0189_BD12RKACXX_JamesWare/Lane2/BWA_gatk_snp_indel_AdapterTrimmed/20aa00254/Bait/20aa00254_GTGAGAGACA.Realigned.recalibrated.OnBait.q8.bam.final.indel.vcf
#			$gatk_indel="$pool_dir/gatk_snp_indel_AdapterTrimmed/$sample_name/Bait/$sample_name.Realigned.recalibrated.OnBait.q8.bam.final.indel.vcf";

			#/data/results/HiSeq/130118_SN674_0199_AC13LGACXX/MYRN_SureSelect/BWA_gatk_snp_indel/20AA02416/Target/20AA02416_AGTCACTA.markDup.Realigned.recalibrated.OnTarget.q8.bam.final.indel.vcf
#			$gatk_indel="$pool_dir/gatk_snp_indel/$sample_name/Target/$sample_name.markDup.Realigned.recalibrated.OnTarget.q8.bam.final.indel.vcf" unless -s $gatk_indel;
		}elsif($machine eq 'MiSeq'){
			$result_root=$miseq_result_root;
			my $pool_dir=$result_root.'/'.$run_name.'/'.$pool_name;
			$pool_dir=$result_root.'/'.$run_name.'/'.$pool_name.'_'.$target_id if -d $result_root.'/'.$run_name.'/'.$pool_name.'_'.$target_id;

			#/data/results/MiSeq/130103_M01389_0002_000000000-A2V7A/Lane2/BWA_gatk_snp_indel/20AA02402/Target/20AA02402_AACGTG.markDup.Realigned.recalibrated.OnTarget.q8.bam.final.snp.vcf
			#/data/results/MiSeq/130531_M01389_0014_000000000-A3F2A/PRDM16_Fluidigm/BWA_gatk_snp_indel/14EG01498a/Target/14EG01498a.Realigned.recalibrated.OnTarget.q8.bam.snp.vcf
			#/data/results/MiSeq/131122_M01389_0027_000000000-A61C8/Nextera_177Gene/gatk_snp_indel/10CD02790/Target/HaplotypeCaller/10CD02790.markDup.Realigned.recalibrated.OnTarget.q8.bam.final.HaplotypeCaller.snp.vcf
			$gatk_snp="$pool_dir/gatk_snp_indel/$sample_name/Target/$sample_name.markDup.Realigned.recalibrated.OnTarget.q8.bam.final.snp.vcf";
			$gatk_snp="$pool_dir/gatk_snp_indel/$sample_name/Target/$sample_name.Realigned.recalibrated.OnTarget.q8.bam.final.snp.vcf" unless -s $gatk_snp;
			$gatk_snp="$pool_dir/gatk_snp_indel/$sample_name/Target/HaplotypeCaller/$sample_name.Realigned.recalibrated.OnTarget.q8.bam.final.HaplotypeCaller.snp.vcf" unless -s $gatk_snp;
			$gatk_snp="$pool_dir/gatk_snp_indel/$sample_name/Target/HaplotypeCaller/$sample_name.markDup.Realigned.recalibrated.OnTarget.q8.bam.final.HaplotypeCaller.snp.vcf" unless -s $gatk_snp;
			$gatk_snp="$pool_dir/gatk_snp_indel/$sample_name/Target/HaplotypeCaller/$sample_name.markDup.Realigned.recalibrated.OnTarget.q15.bam.final.HaplotypeCaller.snp.vcf" unless -s $gatk_snp;
			# /data/results/MiSeq/131122_M01389_0027_000000000-A61C8/Nextera_177Gene/gatk_snp_indel/13G000020/Target/HaplotypeCaller/13G000020.markDup.Realigned.recalibrated.OnTarget.q8.bam.final.HaplotypeCaller.snp.vcf
			#$gatk_snp="$pool_dir/gatk_snp_indel/$old_sample_name/Target/HaplotypeCaller/$old_sample_name.markDup.Realigned.recalibrated.OnTarget.q8.bam.final.HaplotypeCaller.snp.vcf" unless -s $gatk_snp;

			#/data/results/MiSeq/130103_M01389_0002_000000000-A2V7A/Lane2/BWA_gatk_snp_indel/20AA02402/Target/20AA02402_AACGTG.markDup.Realigned.recalibrated.OnTarget.q8.bam.final.indel.vcf
			#/data/results/MiSeq/131122_M01389_0027_000000000-A61C8/Nextera_177Gene/gatk_snp_indel/10CD02790/Target/HaplotypeCaller/10CD02790.markDup.Realigned.recalibrated.OnTarget.q8.bam.final.HaplotypeCaller.indel.vcf
			$gatk_indel="$pool_dir/gatk_snp_indel/$sample_name/Target/$sample_name.markDup.Realigned.recalibrated.OnTarget.q8.bam.final.indel.vcf";
			$gatk_indel="$pool_dir/gatk_snp_indel/$sample_name/Target/$sample_name.Realigned.recalibrated.OnTarget.q8.bam.final.indel.vcf" unless -s $gatk_indel;
			$gatk_indel="$pool_dir/gatk_snp_indel/$sample_name/Target/HaplotypeCaller/$sample_name.Realigned.recalibrated.OnTarget.q8.bam.final.HaplotypeCaller.indel.vcf" unless -s $gatk_indel;
			$gatk_indel="$pool_dir/gatk_snp_indel/$sample_name/Target/HaplotypeCaller/$sample_name.markDup.Realigned.recalibrated.OnTarget.q8.bam.final.HaplotypeCaller.indel.vcf" unless -s $gatk_indel;
			$gatk_indel="$pool_dir/gatk_snp_indel/$sample_name/Target/HaplotypeCaller/$sample_name.markDup.Realigned.recalibrated.OnTarget.q15.bam.final.HaplotypeCaller.indel.vcf" unless -s $gatk_indel;

			# /data/results/MiSeq/131122_M01389_0027_000000000-A61C8/Nextera_177Gene/gatk_snp_indel/13G000020/Target/HaplotypeCaller/13G000020.markDup.Realigned.recalibrated.OnTarget.q8.bam.final.HaplotypeCaller.indel.vcf
		}elsif($machine eq 'NextSeq 500'){
			$result_root=$nextseq_result_root;
			my $pool_dir=$result_root.'/'.$run_name.'/'.$pool_name;
			$pool_dir=$result_root.'/'.$run_name.'/'.$pool_name.'_'.$target_id if -d $result_root.'/'.$run_name.'/'.$pool_name.'_'.$target_id;

			$gatk_snp="$pool_dir/gatk_snp_indel/$sample_name/Target/$sample_name.markDup.Realigned.recalibrated.OnTarget.q8.bam.final.snp.vcf";
			$gatk_snp="$pool_dir/gatk_snp_indel/$sample_name/Target/$sample_name.Realigned.recalibrated.OnTarget.q8.bam.final.snp.vcf" unless -s $gatk_snp;
			$gatk_snp="$pool_dir/gatk_snp_indel/$sample_name/Target/HaplotypeCaller/$sample_name.Realigned.recalibrated.OnTarget.q8.bam.final.HaplotypeCaller.snp.vcf" unless -s $gatk_snp;
			$gatk_snp="$pool_dir/gatk_snp_indel/$sample_name/Target/HaplotypeCaller/$sample_name.markDup.Realigned.recalibrated.OnTarget.q8.bam.final.HaplotypeCaller.snp.vcf" unless -s $gatk_snp;
			$gatk_snp="$pool_dir/gatk_snp_indel/$sample_name/Target/HaplotypeCaller/$sample_name.markDup.Realigned.recalibrated.OnTarget.q15.bam.final.HaplotypeCaller.snp.vcf" unless -s $gatk_snp;

			$gatk_indel="$pool_dir/gatk_snp_indel/$sample_name/Target/$sample_name.markDup.Realigned.recalibrated.OnTarget.q8.bam.final.indel.vcf";
			$gatk_indel="$pool_dir/gatk_snp_indel/$sample_name/Target/$sample_name.Realigned.recalibrated.OnTarget.q8.bam.final.indel.vcf" unless -s $gatk_indel;
			$gatk_indel="$pool_dir/gatk_snp_indel/$sample_name/Target/HaplotypeCaller/$sample_name.Realigned.recalibrated.OnTarget.q8.bam.final.HaplotypeCaller.indel.vcf" unless -s $gatk_indel;
			$gatk_indel="$pool_dir/gatk_snp_indel/$sample_name/Target/HaplotypeCaller/$sample_name.markDup.Realigned.recalibrated.OnTarget.q8.bam.final.HaplotypeCaller.indel.vcf" unless -s $gatk_indel;
			$gatk_indel="$pool_dir/gatk_snp_indel/$sample_name/Target/HaplotypeCaller/$sample_name.markDup.Realigned.recalibrated.OnTarget.q15.bam.final.HaplotypeCaller.indel.vcf" unless -s $gatk_indel;
		}else{
			warn "\e[031mGATKs only for Soid4, 454, 5500XL, HiSeq or MiSeq\e[0m\n" and next;
		}

		warn "\e[31mcannot find $gatk_snp (maybe not run yet?)\e[0m\n" and next unless -s $gatk_snp;
		warn "\e[31mcannot find $gatk_indel (maybe not run yet?)\e[0m\n" and next unless -s $gatk_indel;

		&parse_vcf($sample_id, $gatk_snp);
		&parse_vcf($sample_id, $gatk_indel);
	}#end of @samples

	$sql->finish();
	$dbh->disconnect();

}#end of MAIN

sub parse_vcf{
	my ($sample_id, $file)=@_;
	# [QUAL < 30.0 || QD < 5.0 || HRun > 5 || SB > -0.10 || DP < 4
	# now parse snp results
	#CHROM  POS ID  REF ALT QUAL    FILTER  INFO    FORMAT  LIBR1   
	#chr1	3341540	rs2483236	C	T	433.77	PASS	ABHom=1.00;AC=2;AF=1.00;AN=2;DB;DP=18;Dels=0.00;FS=0.000;HaplotypeScore=0.0000;MLEAC=2;MLEAF=1.00;MQ=60.00;MQ0=0;QD=24.10;SB=-3.410e+02	GT:AD:DP:GQ:PL	1/1:0,18:18:33:462,33,0
	#chr1	3303446	rs2245703	T	C	179.77	PASS	ABHet=0.417;AC=1;AF=0.500;AN=2;BaseQRankSum=2.533;DB;DP=12;Dels=0.00;FS=0.000;HaplotypeScore=0.0000;MLEAC=1;MLEAF=0.500;MQ=60.00;MQ0=0;MQRankSum=0.689;QD=14.98;ReadPosRankSum=1.000;SB=-3.300e+01	GT:AD:DP:GQ:PL	0/1:5,7:12:99:208,0,124
	#chr1	10190884	rs2295294	A	T	1832.77	PASS	ABHet=0.609;AC=1;AF=0.500;AN=2;BaseQRankSum=4.305;DB;DP=225;Dels=0.00;FS=0.000;HaplotypeScore=5.6937;MLEAC=1;MLEAF=0.500;MQ=57.80;MQ0=0;MQRankSum=3.136;QD=8.15;ReadPosRankSum=0.114;SB=-1.112e+03	GT:AD:DP:GQ:PL	0/1:137,88:211:99:1861,0,2772
	#chr1	16344625	rs945417	C	G	1862.77	PASS	ABHom=1.00;AC=2;AF=1.00;AN=2;DB;DP=64;Dels=0.00;FS=0.000;HaplotypeScore=0.7340;MLEAC=2;MLEAF=1.00;MQ=59.42;MQ0=0;QD=29.11;SB=-9.490e+02	GT:AD:DP:GQ:PL	1/1:0,64:64:99:1891,144,0
	#chr1    6272137 rs709208    A   G   182.54  StandardFilters AB=0.69;AC=1;AF=0.50;AN=2;DB;DP=68;Dels=0.01;HRun=6;HaplotypeScore=32.8715;MQ=33.21;MQ0=0;QD=2.68;SB=18.04;sumGLbyD=3.13    GT:AD:DP:GQ:PL  0/1:42,19:35:99:213,0,764
	open (VAR, "<$file") or die "cannot open $file:$!\n"; 
	my $is_snp= $file=~/snp.vcf$/ ? 1:0;
	while(<VAR>){
		chomp;
		next if $_=~/^#/;
		my ($chr,$g_start,$known,$reference,$genotype,$qual,$filter,$info,$format,$data)=split(/\t/,$_);
		$filter='\\N' if $filter eq '.';
		$qual = '\\N' if $qual eq '.';
		$known = '\\N' if $known eq '.';

		## info ##
		$info=~s/DB;//g; $info=~s/DS;//g; $info=~s/STR//g; # No value assinged (e.g. DB;DS;STR;)
		my @dummy=split(/;/,$info);
		my %att= map split(/=/), @dummy; #crash unless $_ contains '='

		#my $ab=exists $att{AB}? $att{AB}:'\\N'; # $att{AB} could be null #GATK equal or less than v1.5-20-gd3f2bc4
		#foreach my $dum_key(keys %att){print $dum_key,"\t",$att{$dum_key},"\n"}
		my $ab_hom=$att{ABHom} if exists $att{ABHom}; # GATK equal or more than v2.3-9-ge5ebf34
		my $ab_het=$att{ABHet} if exists $att{ABHet}; # GATK equal or more than v2.3-9-ge5ebf34
		my $ab=$ab_hom? $ab_hom : $ab_het;
		$ab='\N' unless $ab;
		my $ac=exists $att{AC}? $att{AC}:'\\N'; # $att{AC} could be undef 
		my $af=exists $att{AF}? $att{AF}:'\\N'; # $att{AF} could be undef 
		my $an=exists $att{AN}? $att{AN}:'\\N'; # $att{AN} could be undef 
		my $t_dp=exists $att{DP}? $att{DP}:'\\N'; # $att{DP} could be undef 
		my $hrun=exists $att{HRun}? $att{HRun}:'\\N'; 
		my $hscore=exists $att{HaplotypeScore}? $att{HaplotypeScore}:'\\N'; 
		my $mq=exists $att{MQ}? $att{MQ}:'\\N'; 
		my $qd=exists $att{QD}? $att{QD}:'\\N'; 
		my $sb=exists $att{SB}? $att{SB}:'\\N'; 

		# GT:AD:DP:GQ:PL
		my @format=split(/:/,$format);
		# 0/1:42,19:35:99:213,0,764
		my @data=split(/:/,$data);

		my %data;
		for(my$i=0;$i<$#format+1;$i++){
			$data{$format[$i]}=$data[$i];
		}

		my $gt=exists $data{GT}? $data{GT}:'\\N'; # not null 
		my $pl=exists $data{PL}? $data{PL}:'\\N'; # $data{PL} could be undef 
		my $ad=exists $data{AD}? $data{AD}:0; # $data{AD} could be undef 
		my $f_dp=exists $data{DP}? $data{DP}:0; # $data{DP} could be undef 
		my $gq=exists $data{GQ}? $data{GQ}:0; # $data{DP} could be undef 

		# SNP
		my $snp_type;
		if($is_snp){
			$snp_type='SNP';
			foreach my $geno(split(/,/,$genotype)){
				#[QC] is the length same?
				if(length($reference)==length($geno)){
					print "0\t$sample_id\t$snp_type\t$chr\t$g_start\t$g_start\t$reference\t$geno\t$qual\t$filter\t$known\t$ab\t$ac\t$af\t$an\t$t_dp\t$hrun\t$hscore\t$mq\t$qd\t$sb\t$info\t$gt\t$ad\t$f_dp\t$gq\t$pl\n" unless $DEBUG;
				}else{
					die "\e[31mlength of $reference NOT same with $geno for SNP?\n$_\e[0m\n";
				}
			}
		# Indel
		}else{
			foreach my $geno(split(/,/,$genotype)){
				my ($ref,$mut,$start,$end); #formatted
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
				print "0\t$sample_id\t$snp_type\t$chr\t$start\t$end\t$ref\t$mut\t$qual\t$filter\t$known\t$ab\t$ac\t$af\t$an\t$t_dp\t$hrun\t$hscore\t$mq\t$qd\t$sb\t$info\t$gt\t$ad\t$f_dp\t$gq\t$pl\n" unless $DEBUG;
			}
		}#end of if $is_snp
	}#end of while
	close VAR;
}

sub usage{
	die "\e[32m[USAGE] perl $0 --run_name [run_name] --pool_name=[pool_name] --sample_name=[sample_name]\e[0m\n";
}
