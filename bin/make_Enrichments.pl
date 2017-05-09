#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use DBI;

#use lib '/data2/users_data2/kingsley/CardioDBS/Perl/lib'; #ck
#use Sung::Manager::Config;

my $dbconfig='';
my $run_name='';
my $CARDIODB_ROOT='';
my $DEBUG;
my $result_root='';
my $miseq_result_root='';
my $nextseq_result_root='';


GetOptions
(
  'debug!'                =>      \$DEBUG,
  'run_name=s'            =>      \$run_name,
  'dbconfig=s'		  =>	  \$dbconfig,
  'CARDIODB_ROOT=s'	  =>	  \$CARDIODB_ROOT,
  'miseq_result_path=s'	  =>	  \$miseq_result_root,
  'nextseq_result_path=s' =>      \$nextseq_result_root
) or &usage();

warn "\e[33mrequired argument value for --run_name\e[0m\n" and &usage() unless $run_name;


MAIN: {
  my $sql;
  my @sql_out;

  my $dbh = DBI->connect("DBI:mysql:;mysql_read_default_file=$dbconfig",undef,undef)
    or die "Couldn't connect to database: " . DBI->errstr;

  my $where=$run_name eq 'all'? "" : "where s.run_name='$run_name'";

  $sql=$dbh->prepare("SELECT distinct r.machine, s.run_name,s.pool_name,s.target_id FROM Samples s JOIN Runs r ON s.run_id=r.id $where")
    or die "Couldn't prepare statement: " . $dbh->errstr;
  $sql->execute()
    or die "Couldn't execute statement: " . $sql->errstr;

  my ($result_root,$sample_cov_file,$cds_cov_file);

  while (@sql_out = $sql->fetchrow_array()){
      my ($machine, $run_name,$pool_name,$target_id)=@sql_out;
        die "\e[31mNo entries for your input\e[0m\n" unless scalar@sql_out;
	
      if($machine eq 'HiSeq'){
          $result_root='/data/results/HiSeq';
      }elsif($machine eq 'MiSeq'){
          $result_root=$miseq_result_root;
      }elsif($machine eq 'NextSeq 500'){
          $result_root=$nextseq_result_root;
      }else{
          warn "\e[031mOnly for Soid4, 454, 5500XL, HiSeq or MiSeq\e[0m\n" and next;
      }

      $sample_cov_file="$result_root/$run_name/Coverage_Report_v2/ProteinCodingTarget169gene/SummaryOutput_ProteinCodingTarget169gene_$run_name.txt";
      $cds_cov_file="$result_root/$run_name/Coverage_Report_v2/ProteinCodingTarget169gene/CallableByExon_ProteinCodingTarget169gene_$run_name\_$pool_name.txt";
      $cds_cov_file="$result_root/$run_name/Coverage_Report_v2/ProteinCodingTarget169gene/CallableByExon_ProteinCodingTarget169gene_$run_name\_$pool_name\_$target_id.txt" unless -s $cds_cov_file;

      warn "\e[31mcannot find $sample_cov_file \e[0m\n" and next unless -s $sample_cov_file;
      warn "\e[31mcannot find $cds_cov_file \e[0m\n" and next unless -s $cds_cov_file;

      #SampleEnrichments
      &make_SampleEnrichments($sample_cov_file,$dbh);
      #CodingEnrichments
      &make_CodingEnrichments($cds_cov_file,$dbh);

  } #end of while loop

  $sql->finish();
  $dbh->disconnect();

} #end of MAIN

sub make_SampleEnrichments{
  my ($infile, $dbh) = @_;
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
      
      #get sample_id
      my $sample_id;

      my $sth=$dbh->prepare_cached("select id from Samples where run_name=? and sample_name=?")
          or die "Couldn't prepare statement: " . $dbh->errstr;
      $sth->execute($run_name,$sample_name)
          or die "Couldn't execute statement: " . $sth->errstr;

      $sample_id = $sth->fetchrow_array();
      chomp($sample_id);
          warn "no sample_id for $sample_name\n" and next unless $sample_id;

      print OUT $sample_id,"\t";

      for(my $i=0;$i<scalar@dummy_array;$i++){
          print OUT $dummy_array[$i],"\t";
      }

      print OUT "\n";

      $sth->finish();
  } #end of while loop

  close IN;
  close OUT;

} #end of make_SampleEnrichments

sub make_CodingEnrichments{
  my ($infile, $dbh)=@_;
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
	
              #get sample_id
              my $sample_id;
	
              my $sth=$dbh->prepare_cached("select id from Samples where run_name=? and sample_name=?")
                  or die "Couldn't prepare statement: " . $dbh->errstr;
              $sth->execute($run_name,$sample_name)
                  or die "Couldn't execute statement: " . $sth->errstr;
              
              $sample_id = $sth->fetchrow_array();
              chomp($sample_id);
                  warn "no sample_id for $sample_name\n" and next unless $sample_id;

              $sample_ids[$i]{$sample_name}=$sample_id;
              $sth->finish();
         } #end of for
      } #end of if
      else{
          for(my $i=5;$i<scalar@dummy_array;$i++){
              #the start position from the bed format is 0-based coordinate
              #correct this to the Ensembl format
              my $one_base_start=$dummy_array[1]+1;
              print OUT "0\t$sample_ids[$i]{$sample_names[$i]}\t$sample_names[$i]\t$dummy_array[3]\t$dummy_array[0]\t$one_base_start\t$dummy_array[2]\t$dummy_array[$i]\n";
          } #end of for
     } #end of if-else
  } #end of while

  close IN;
  close OUT;
} #end of make_CodingEnrichments

sub usage{
	die "\e[32m[USAGE] perl $0 --run_name [run_name] \e[0m\n";
}
