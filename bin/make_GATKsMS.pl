#!/usr/bin/perl -w
use strict;
die "\e[32m[USAGE] perl $0 [ROOT_DIR_OF_GATKMS] [GROUP_NAME]\e[0m\n" unless $#ARGV==1;

my $DEBUG=0; #
# /data/results/5500xl/projects/lifescope/SOLiD4_5500xl_Merge/GATK_Multisample/Family/SGH_1_BrS/Target/
my $output_dir="/data/Develop/CardioDB/Dump";
mkdir $output_dir.'/'.'GATKsMS' unless -d "$output_dir/GATKsMS";
mkdir $output_dir.'/'.'GATKsMSformat' unless -d "$output_dir/GATKsMSformat";

my $gatkms_dir=$ARGV[0]; 
die "No such file\n" unless -d $gatkms_dir;
my $group_name=$ARGV[1]; 
my @gatk_files;

MAIN: {
	# /data/results/5500xl/projects/lifescope/SOLiD4_5500xl_Merge/GATK_Multisample/Family/SGH_1_BrS/Target/SGH_1_BrS.final.snp.vcf
	# /data/results/5500xl/projects/lifescope/SOLiD4_5500xl_Merge/GATK_Multisample/Family/SGH_1_BrS/Target/SGH_1_BrS.final.indel.vcf
	# /data/results/HiSeq/120803_SN674_0189_BD12RKACXX_JamesWare/MultiSample/Bait/MultiSample.final.snp.vcf
	# /data/results/HiSeq/120803_SN674_0189_BD12RKACXX_JamesWare/MultiSample/Bait/MultiSample.final.indel.vcf
	my $gatk_snp="$gatkms_dir/$group_name.final.snp.vcf";
	my $gatk_indel="$gatkms_dir/$group_name.final.indel.vcf";

	die "\e[32mcannot find $gatk_snp (maybe not run yet?)\e[0m\n" unless -s $gatk_snp;
	die "\e[32mcannot find $gatk_indel (maybe not run yet?)\e[0m\n" unless -s $gatk_indel;

	push @gatk_files, $gatk_snp;
	push @gatk_files, $gatk_indel;
	open (MS, "+>$output_dir/GATKsMS/GATKsMS.$group_name.txt") or die "$!\n";
	open (FORMAT, "+>$output_dir/GATKsMSformat/GATKsMSformat.$group_name.txt") or die "$!\n";

	print "\e[032mWriting to files...\e[0m\n";
	&parse_and_dump();

	close MS;
	close FORMAT;

	#/data/results/HiSeq/Reads/WholeExome_Edinburgh/131125_0068_H7WA2ADXX/snps/batch1_UG_recalibrated_snps_and_indels.vcf.gz
}

sub parse_and_dump{
	# CHROM  POS ID  REF ALT QUAL    FILTER  INFO    FORMAT  OPMD_1  OPMD_2  OPMD_3  OPMD_4
	# chr1    63516   .   A   G   178.33  StandardFilters AB=0.47;AC=2;AF=0.50;AN=4;DP=20;Dels=0.00;HRun=0;HaplotypeScore=2.8389;MQ=31.27;MQ0=0;QD=9.39;SB=-0.01;sumGLbyD=11.22   GT:AD:DP:GQ:PL  0/1:4,5:6:77.51:78,0,85 0/1:5,5:8:67.89:136,0,68    ./. ./.
	#
	my $gid=0;
	foreach my $file(@gatk_files){
		warn "\e[31mparsing $file\e[0m\n";

		# get sample lists
		my $dummy=`grep "#CHROM" $file`;
		die "grep \"CHROM\" failed\n" unless $dummy;
		$dummy=~m/CHROM\s+POS\s+ID\s+REF\s+ALT\s+QUAL\s+FILTER\s+INFO\s+FORMAT\s+(.*)\n/;
		die "no sample information" unless $1;
		my @samples=split(/\t/,$1);
		die "no samples infomration found\n" unless @samples;

		# open vcf file
		open (VCF, "<$file") or die "cannot open $file:$!\n"; 
		my $is_snp= $file=~/snp.vcf$/ ? 1:0;
		#my $snp_type= $file=~/snp.vcf$/ ? 'SNP':'Indel';
		while(<VCF>){
			chomp;
			next if $_=~/^#/;

			my ($chr,$g_start,$known,$reference,$genotype,$qual,$filter,$info,$format,@sample_data)=split(/\t/,$_);
			$filter='\\N' if $filter eq '.';
			$qual = '\\N' if $qual eq '.';
			$known = '\\N' if $known eq '.';
			
			## info ##
			$info=~s/DB;//g; $info=~s/DS;//g; $info=~s/STR//g; # No value assinged (e.g. DB;DS;STR;)
			my @dummy=split(/;/,$info);
			my %att= map split(/=/), @dummy; #crash unless $_ contains '='

			my $ab=exists $att{ABHet}? $att{ABHet}:'\\N'; # GATK equal or more than v2.3-9-ge5ebf34
			$ab=exists $att{ABHom}? $att{ABHom}:'\\N'; # GATK equal or more than v2.3-9-ge5ebf34
			my $ac=exists $att{AC}? $att{AC}:'\\N'; # $att{AC} could be undef 
			my $af=exists $att{AF}? $att{AF}:'\\N'; # $att{AF} could be undef 
			my $an=exists $att{AN}? $att{AN}:'\\N'; # $att{AN} could be undef 
			my $t_dp=exists $att{DP}? $att{DP}:'\\N'; # $att{DP} could be undef 
			my $hrun=exists $att{HRun}? $att{HRun}:'\\N'; 
			my $mq=exists $att{MQ}? $att{MQ}:'\\N'; 
			my $qd=exists $att{QD}? $att{QD}:'\\N'; 
			my $sb=exists $att{SB}? $att{SB}:'\\N'; 

			# SNP
			my $snp_type;
			if($is_snp){
				$gid++;
				$snp_type='SNP';
				foreach my $geno(split(/,/,$genotype)){
					#[QC] is the length same?
					if(length($reference)==length($geno)){
						print MS "0\t$group_name\t$gid\t$chr\t$snp_type\t$g_start\t$g_start\t$reference\t$geno\t$qual\t$filter\t$known\t$ab\t$ac\t$af\t$an\t$t_dp\t$hrun\t$qd\t$sb\t$info\n";
					}else{
						die "\e[31mlength of $reference NOT same with $geno for SNP?\n$_\e[0m\n";
					}
				}
			# Indel
			}else{
				foreach my $geno(split(/,/,$genotype)){
					my ($ref,$mut,$start,$end); #formatted
					if(length($reference) > length($geno)){
						$gid++;
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
						$gid++;
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
					print MS "0\t$group_name\t$gid\t$chr\t$snp_type\t$start\t$end\t$ref\t$mut\t$qual\t$filter\t$known\t$ab\t$ac\t$af\t$an\t$t_dp\t$hrun\t$qd\t$sb\t$info\n";
				}
			}#end of if $is_snp

			## format ##
			my @format=split(/:/,$format);

			# data for each sample (e.g. 14sg00082DN 14sg00083DN 14sg00084DN 14sg00085DN 14sg00086DN 14sg00087DN)
			#GT:AD:DP:GQ:PL  0/1:3,3:2:25.53:28,0,26 ./. 0/1:1,1:2:27.42:27,0,31 1/1:0,4:2:6.02:68,6,0   0/1:9,5:11:99:110,0,228 ./.
			# ./.:.:1:.:0,0,0 (01/09/2012 10:37:05 AM)
			for(my$j=0;$j<$#samples+1;$j++){ 
				my %data;
				for(my$i=0;$i<$#format+1;$i++){
					my @data=split(/:/,$sample_data[$j]);
					$data{$format[$i]}=$data[$i] if $#format==$#data;
				}

				my $gt=defined $data{GT}? $data{GT} eq './.'? '\\N':$data{GT} :'\\N'; # not null 
				my $ad=defined $data{AD}? $data{AD} eq '.'? '\\N':$data{AD} :'\\N'; # $data{AD} could be undef 
				my $f_dp=defined $data{DP}? $data{DP} eq '.'? '\\N':$data{DP} :'\\N'; # $data{DP} could be undef 
				my $gq=defined $data{GQ}? $data{GQ} eq '.'? '\\N':$data{GQ} :'\\N'; # $data{DP} could be undef 
				my $pl=defined $data{PL}? $data{PL} eq '.'? '\\N':$data{PL} :'\\N'; # $data{DP} could be undef 
				print FORMAT "0\t$group_name\t$gid\t$samples[$j]\t$gt\t$ad\t$f_dp\t$gq\t$pl\n";
			}
		}
		close VCF;
	}#end of foreach
}
