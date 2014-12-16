#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use lib '/data/Develop/Perl/lib';
use Sung::Manager::Config;

# Get DB config
my $db_config='/data/Develop/Perl/lib/Sung/Manager/Config/db.conf';
my $config=Sung::Manager::Config->get_config_from_file($db_config);

my $host=$config->{db}{host};
my $user=$config->{db}{user};
my $passwd=$config->{db}{passwd};
my $CARDIODB=$config->{db}{cardiodb};
my $CARDIODB_ROOT=$config->{CARDIODB_ROOT};

my $run_name='';
my $DEBUG;
GetOptions
(
	'debug!' => \$DEBUG,
    'run_name=s'	=>	\$run_name,
) or &usage();

warn "\e[33mrequired argument value for --run_name\e[0m\n" and &usage() unless $run_name;


MAIN: {
	my $sql;
	my $where=$run_name eq 'all'? '' : "where s.run_name='$run_name'";
	$sql=`mysql --skip-column-names -e "
	SELECT distinct r.platform, s.run_name,s.pool_name,s.target_id FROM $CARDIODB.Samples s JOIN $CARDIODB.Runs r ON s.run_id=r.id $where"`;

	my ($result_root,$sample_cov_file,$cds_cov_file);
	my @reports=split(/\n/,$sql);
	die "\e[31mNo entries for your input\e[0m\n" unless scalar@reports;
	foreach (@reports){
		my ($platform, $run_name,$pool_name,$target_id)=split(/\t/,$_);

		if($platform eq 'SOLiD4'){
			$result_root='/data/results/s0464.pssc';
			next;
		}elsif($platform eq '454'){
			$result_root='/data/results/454';
			next;
		}elsif($platform eq '5500xl'){
			$result_root='/data/results/5500xl/projects/lifescope';
		}elsif($platform eq 'HiSeq'){
			$result_root='/data/results/HiSeq';
			#/data/results/HiSeq/130320_SN172_0376_AD1Y6JACXX/Coverage_Report/
			#SummaryOutput_ProteinCodingTarget_130320_SN172_0376_AD1Y6JACXX.txt
			#CallableByRun_ProteinCodingTarget_130320_SN172_0376_AD1Y6JACXX_Hari_AB_S0411142.txt
			#CallableBySample_ProteinCodingTarget_130320_SN172_0376_AD1Y6JACXX_Hari_AB_S0411142.txt
			#PerOfCallableBy_ProteinCodingTarget_130320_SN172_0376_AD1Y6JACXX_Hari_AB_S0411142.txt
		}elsif($platform eq 'MiSeq'){
			$result_root='/data/results/MiSeq';
			#/data/results/MiSeq/130531_M01389_0014_000000000-A3F2A/Coverage_Report/
			#SummaryOutput_ProteinCodingTarget_130531_M01389_0014_000000000-A3F2A.txt
			#CallableByRun_ProteinCodingTarget_130531_M01389_0014_000000000-A3F2A_PRDM16_Fluidigm.txt
			#CallableBySample_ProteinCodingTarget_130531_M01389_0014_000000000-A3F2A_PRDM16_Fluidigm.txt
			#PerOfCallableBy_ProteinCodingTarget_130531_M01389_0014_000000000-A3F2A_PRDM16_Fluidigm.txt
			#
			#
			#/data/results/MiSeq/130613_M01389_0016_000000000-A4TDC/Coverage_Report/
			#SummaryOutput_ProteinCodingTarget_130613_M01389_0016_000000000-A4TDC.txt
			#CallableByRun_ProteinCodingTarget_130613_M01389_0016_000000000-A4TDC_XT2_177gene_0482031.txt
			#CallableBySample_ProteinCodingTarget_130613_M01389_0016_000000000-A4TDC_XT2_177gene_0482031.txt
			#PerOfCallableBy_ProteinCodingTarget_130613_M01389_0016_000000000-A4TDC_XT2_177gene_0482031.txt
			#
		}else{
			warn "\e[031mOnly for Soid4, 454, 5500XL, HiSeq or MiSeq\e[0m\n" and next;
		}

		$sample_cov_file="$result_root/$run_name/Coverage_Report/SummaryOutput_ProteinCodingTarget_$run_name.txt";
		$cds_cov_file="$result_root/$run_name/Coverage_Report/PerOfCallableBy_ProteinCodingTarget_$run_name\_$pool_name.txt";
		$cds_cov_file="$result_root/$run_name/Coverage_Report/PerOfCallableBy_ProteinCodingTarget_$run_name\_$pool_name\_$target_id.txt" unless -s $cds_cov_file;

		warn "\e[31mcannot find $sample_cov_file \e[0m\n" and next unless -s $sample_cov_file;
		warn "\e[31mcannot find $cds_cov_file \e[0m\n" and next unless -s $cds_cov_file;

		# SampleEnrichments
		&make_SampleEnrichments($sample_cov_file);
		# CodingEnrichments
		&make_CodingEnrichments($cds_cov_file);

=per gene
#CallableByRun_ProteinCodingTarget
SELECT run_name, pool_name, hgnc, MAX(t.callable)
FROM (
	# CallableBySample_ProteinCodingTarget
	SELECT run_name, pool_name, sample_id, c.sample_name, hgnc, SUM(callable_pct*(cds_end-cds_start+1))/SUM(cds_end-cds_start+1) callable 
	FROM CodingEnrichments c
	JOIN Samples s ON c.sample_id=s.id
	GROUP BY run_name, pool_name, sample_id, hgnc
	) t
GROUP BY run_name, pool_name, hgnc

#SummaryCollable
SELECT run_name, pool_name, sample_id, c.sample_name, SUM(callable_pct*(cds_end-cds_start+1))/SUM(cds_end-cds_start+1) callable 
FROM CodingEnrichments c
JOIN Samples s ON c.sample_id=s.id
GROUP BY run_name, pool_name, sample_id
ORDER BY c.id
=cut

	}#end of @reports
}#end of MAIN

sub make_SampleEnrichments{
	my $infile=shift;
	warn "\e[032m$infile\e[0m\n";

	my $cnt=0;
	open(IN, "$infile") or die "cannot open $infile\n";
	open(OUT, "+>$CARDIODB_ROOT/Dump/Enrichments/SampleEnrichments.$run_name.txt") or die "cannot make a file:$!\n";
	while(<IN>){
		chomp;$cnt++;
		next if $cnt==1;

		print OUT "0\t$infile\t";
		my @dummy_array=split(/\t/);
		#die "should be 37 columns\n" unless scalar@dummy_array==37;
		my $sample_name=$dummy_array[0];
		# get sample_id
		my $sample_id=`mysql -h $host -u $user -p$passwd --skip-column-names $CARDIODB -e "select id from Samples where run_name='$run_name' and sample_name='$sample_name'"`; chomp($sample_id);
		unless($sample_id){
			$sample_id=`mysql -h $host -u $user -p$passwd --skip-column-names $CARDIODB -e "select id from Samples where run_name='$run_name' and old_sample_name='$sample_name'"`; chomp($sample_id);
		}
		warn "no sample_id for $sample_name\n" and next unless $sample_id;
		print OUT $sample_id,"\t"; 
		for(my $i=0;$i<scalar@dummy_array;$i++){
			next if $i==30; #Diff(mean-med)
			print OUT $dummy_array[$i],"\t";
		}
		print OUT "\n";
	}
	close IN;
	close OUT;
}#end of make_SampleEnrichments

sub make_CodingEnrichments{
	my $infile=shift;
	warn "\e[032m$infile\e[0m\n";

	my $cnt=0;
	open(IN, "$infile") or die "cannot open $infile\n";
	open(OUT, "+>$CARDIODB_ROOT/Dump/Enrichments/CodingEnrichments.$run_name.txt") or die "cannot make a file:$!\n";
	my (@sample_names,@sample_ids); # @cds_samples: array of hash
	while(<IN>){
		chomp;$cnt++;
		my @dummy_array=split(/\t/);
		if($cnt==1){
			for(my $i=5;$i<scalar@dummy_array;$i++){
				$sample_names[$i]=$dummy_array[$i];
				my $sample_name=$sample_names[$i];
				# get sample_id
				my $sample_id=`mysql -h $host -u $user -p$passwd --skip-column-names $CARDIODB -e "select id from Samples where run_name='$run_name' and sample_name='$sample_name'"`; chomp($sample_id);
				unless($sample_id){
					$sample_id=`mysql -h $host -u $user -p$passwd --skip-column-names $CARDIODB -e "select id from Samples where run_name='$run_name' and old_sample_name='$sample_name'"`; chomp($sample_id);
				}
				warn "no sample_id for $sample_name\n" unless $sample_id;
				
				$sample_ids[$i]{$sample_name}=$sample_id;
			}
		}else{
			for(my $i=5;$i<scalar@dummy_array;$i++){
				# the start position from the bed format is 0-based coordinate
				# correct this to the Ensembl format
				my $one_base_start=$dummy_array[1]+1;
				print OUT "0\t$sample_ids[$i]{$sample_names[$i]}\t$sample_names[$i]\t$dummy_array[3]\t$dummy_array[0]\t$one_base_start\t$dummy_array[2]\t$dummy_array[$i]\n";
			}
		}
	}
	close IN;
	close OUT;
}# end of make_CodingEnrichments

sub usage{
	die "\e[32m[USAGE] perl $0 --run_name [run_name] \e[0m\n";
}
