#!/usr/bin/perl -w
=d
this script makes two text dump files for the following two tables:
1. EnMSAs
2. EnFamilies
3. EnMembers
=cut

my $DEBUG=1;
use strict;
use Bio::EnsEMBL::Registry;
use Bio::AlignIO;
use Bio::SeqIO;
use IO::File;
use Getopt::Long;

#use lib '/data/Develop/Perl/lib';
#use Sung::Manager::Config;

my $db='';
my $dbhost='';
my $dbport='';
my $dbuser='';
my $dbpass='';
my $CARDIODB_ROOT='';


my ($make_fasta, $make_family, $make_member, $make_aln);
GetOptions
(
	'db=s'               	=> \$db,
	'dbhost=s'           	=> \$dbhost,
	'dbport=s'           	=> \$dbport,
	'dbuser=s'           	=> \$dbuser,
	'dbpass=s'            	=> \$dbpass,
	'CARDIODB_ROOT=s'	=> \$CARDIODB_ROOT,
	'make_fasta!' 		=> \$make_fasta,
	'make_family!'		=> \$make_family,
	'make_member!' 		=> \$make_member,
	'make_aln!' 		=> \$make_aln,
);
#&usage() and die unless @ARGV;

#############################################################
## Get DB connection to ENSEMBL #############################
## local ensembl registry: ~/.ensembl_api.conf ##############
#############################################################
my $reg = "Bio::EnsEMBL::Registry";
my $reg_config = "/other/CardioDBS/ensembl_api.conf";
$reg->load_all($reg_config); # from ENSEMBL_RETISTRY (check $ENSEMBL_RERISTRY env)

# get the MemberAdaptor
my $member_adaptor = Bio::EnsEMBL::Registry->get_adaptor('Multi','compara','SeqMember');
die "no \$member_adaptor\n" and exit(0) unless $member_adaptor;
my $family_adaptor = Bio::EnsEMBL::Registry->get_adaptor('Multi','compara','Family');
die "no \$family_adaptor\n" and exit(0) unless $family_adaptor;

# Get DB config
#my $db_config='/data/Develop/Perl/lib/Sung/Manager/Config/db.conf';
#my $config=Sung::Manager::Config->get_config_from_file($db_config);
#my $host=$config->{db}{host};
#my $db=$config->{db}{cardiodb};
#my $user=$config->{db}{user};
#my $passwd=$config->{db}{passwd};

my $aln_root='/other/CardioDBS/Data/MSA';
mkdir $aln_root unless -d $aln_root;
my $dump_root='/other/CardioDBS/Dump/Alignments';
mkdir $dump_root unless -d $dump_root;

my $format='fasta'; #alnment format

MAIN: {
	# --make_family --make_member
	my ($fam_ref,$mem_ref)=&get_distinct_families();

	&create_aln_fasta($fam_ref) if $make_fasta;

	# --make_aln
	&parse_aln_files($fam_ref,$mem_ref) if $make_aln;
}

sub create_aln_fasta{
	my $fam=shift;
	my $cnt;
	for (keys %{$fam}){
		$cnt++;
		my $family= $family_adaptor->fetch_by_stable_id($_);
		print "[$cnt]",$family->stable_id,"\n" if $DEBUG;

		unless(-s "$aln_root/$_.fa"){
			my $FH=IO::File->new(">$aln_root/$_.fa");
			my $simple_align = $family->get_SimpleAlign();
			my $alignIO = Bio::AlignIO->newFh(
				-interleaved => 0,
				-fh          => $FH,
				-format      => "$format",
				-idlength    => 20);

			print $alignIO $simple_align;
			$FH->close;
		}
	}
}

# fam_name member_name
sub parse_aln_files{
	my $fam_ref=shift;
	my $mem_ref=shift;

	my $ALN=IO::File->new(">$dump_root/EnMSAs.txt");

	my $cnt_fam;
	for my $fam_name (keys %{$fam_ref}){
		$cnt_fam++;
		print "[$cnt_fam]parsing $fam_name\n" if $DEBUG;

		my $input=$aln_root."/$fam_name.fa";
		next unless -s $input;
		my $in = Bio::SeqIO->new(-format => "$format", -file=>"$input");
		while( my $result = $in->next_seq) {
			my ($entry, $from_to)=split('/', $result->id);
			my ($cnt_aln, $cnt_tmp, $cnt_res);
			foreach my $res(split('', $result->seq)){
				$cnt_aln++;
				$cnt_tmp++ unless $res eq '-';
				$cnt_res=$res eq '-'? '\\N':$cnt_tmp;

				# id memr_id res aln_pos res_num
				print $ALN "0\t",$mem_ref->{$entry},"\t$res\t$cnt_aln\t$cnt_res\n";
			}
		}#endof while $result 
	}

	$ALN->close;
}


sub get_distinct_families{
	print "Compiling distinct families...\n" if $DEBUG;

	my %unique_fam;
	my $query='select distinct ensp from V2Ensembls'; 
	my $sql=`mysql -h 127.0.0.1 -u cardiodbs_admin -pcardiodbs_admin_pass -P 3320 cardiodbs_devel_test --skip-column-name -e "$query"`;
	die "No entries\n" unless defined $sql;

	for(split(/\n/,$sql)){
		my $member = $member_adaptor->fetch_by_source_stable_id('ENSEMBLPEP',$_);
		next unless $member;

		my $families = $family_adaptor->fetch_all_by_Member($member);
		next unless $families;

		foreach my $family (@{$families}) {
			next unless $family->stable_id;
			unless($unique_fam{$family->stable_id}){
				$unique_fam{$family->stable_id}++;
			}
		}
	}

	my %source_hash=(
		'ENSEMBLPEP'=>1,
		'ENSEMBLGENE'=>2,
		'Uniprot/SWISSPROT'=>3,
		'Uniprot/SPTREMBL'=>4,
	);
	my $FAM=IO::File->new(">$dump_root/EnFamilies.txt") if $make_family;
	my $MEM=IO::File->new(">$dump_root/EnMembers.txt") if $make_member;

	my $cnt_fam=0;
	my $cnt_mem=0;
	my %fam; #key: family name, value: index;
	my %mem; #key: member name, value: index;
	for my $fam_name (keys %unique_fam){
		$cnt_fam++;
		print "[$cnt_fam]processing $fam_name\n" if $DEBUG;

		my $family= $family_adaptor->fetch_by_stable_id($fam_name);
		my $des=$family->description? $family->description : '\N';
		$des=$des eq 'UNKNOWN'? '\N' : $des;
		my $des_score=$family->description_score? $family->description_score : '\N';

		# family_id family_name description
		print $FAM "$cnt_fam\t$fam_name\t$des\t$des_score\n" if $make_family;
		$fam{$fam_name}=$cnt_fam;

		for my $member (@{$family->get_all_Members}){
			next unless $member->source_name;
			my $source_name=$member->source_name? $member->source_name : '\N';
			#next if $member->source_name eq 'ENSEMBLGENE';

			$cnt_mem++;
			# member_id family_id member_name tax_id
			my $member_name=$member->stable_id? $member->stable_id : '\N';
			my $taxon_id=$member->taxon_id? $member->taxon_id : '\N';
			print $MEM "$cnt_mem\t$cnt_fam\t$member_name\t$taxon_id\t$source_hash{$source_name}\n" if $make_member;
			$mem{$member_name}=$cnt_mem;
		}
	}

	$FAM->close if $make_family;
	$MEM->close if $make_member;
	return (\%fam,\%mem);
}

sub usage{
	print "\e[32m perl $0 --make_fasta : make alignment files /data/Develop/CardioDB/Data/MSA\e[0m\n";
	print "\e[32m perl $0 --make_family: make EnFamilies.txt file Dump/EnFamilies \e[0m\n";
	print "\e[32m perl $0 --make_member: make EnMembers.txt file Dump/EnMembers \e[0m\n";
	print "\e[32m perl $0 --make_aln: make EnMSAs.txt Dump/EnMSAs \e[0m\n";
}
