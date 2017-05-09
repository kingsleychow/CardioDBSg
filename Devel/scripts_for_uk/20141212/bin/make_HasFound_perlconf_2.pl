#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use DBI;
use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Sequence qw(reverse_comp);

#my $db='';
#my $dbhost='';
#my $dbport='';
#my $dbuser='';
#my $dbpass='';
my $dbconfig='';
my $CARDIODB_ROOT='';

my $DEBUG=0; #

my ($is_sql,$which_db,$all,$region,$start,$end,$allele,$found_only,$not_found_only,$new_entries,$check_alleles,$help);

GetOptions
(
#  'db=s'                => \$db,
#  'dbhost=s'            => \$dbhost,
#  'dbport=s'            => \$dbport,
#  'dbuser=s'            => \$dbuser,
#  'dbpass=s'            => \$dbpass,
  'dbconfig=s'          => \$dbconfig,
  'CARDIODB_ROOT=s'     => \$CARDIODB_ROOT,
  'sql'             	=> \$is_sql,
  'all!'            	=> \$all,  # a flag
  'found_only!'     	=> \$found_only, # a flag
  'not_found_only!' 	=> \$not_found_only, # a flag
  'new_entries!'    	=> \$new_entries, # a flag
  'chr:s'           	=> \$region, #optional
  'start=i'         	=> \$start,
  'end=i'           	=> \$end,
  'allele=s'        	=> \$allele,
  'check_alleles'   	=> \$check_alleles,
  'help!'           	=> \$help,
);

&help and exit(0) if $help;

if(defined $region){&help and exit(0) unless $region=~m/^(1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|X|Y|MT)$/};

#############################################################
## Get DB connection to ENSEMBL #############################
## local ensembl registry: ~/.ensembl_api.conf ##############
#############################################################
my $reg = "Bio::EnsEMBL::Registry";
my $reg_config = "/other/CardioDBS/ensembl_api.conf";
$reg->load_all($reg_config); # from ENSEMBL_RETISTRY (check $ENSEMBL_RERISTRY env)
my $slice_adaptor=$reg->get_adaptor('human','core','slice');
die "Can't get the slice adaptor\n" unless defined $slice_adaptor;

my $vfa= $reg->get_adaptor('human','variation','variationfeature');
die "cannot get VariationFeature adaptor\n" unless defined $vfa;


MAIN:{
	my $dbh;
	my $sql;
        my @sql_out;

	# Using SQL to search against _UnifiedCalls table
	if(defined $is_sql){
		&help() and exit(0) if defined $all and $region;
		&help() and exit(0) unless defined $all or defined $found_only or defined $not_found_only or defined $new_entries or $region;
		my $aux= $region? "where chr='chr$region'" : '';
		$aux=$new_entries? 
			$aux=~/where/? $aux.' and is_new=1': 'where is_new=1'
			:$aux;
		$aux=$found_only? 
			$aux=~/where/? $aux.' and has_found=1': 'where has_found=1'
			:$aux;
		$aux=$not_found_only? 
			$aux=~/where/? $aux.' and has_found=0': 'where has_found=0'
			:$aux;
#		my $db=$which_db eq $cardiodb? $cardiodb : $which_db eq $nectar? $nectar : $which_db;
		
#		my %config = do '/other/CardioDBS/Devel/scripting/cardiodbs_perl.conf';
		$dbh = DBI->connect("DBI:mysql:;mysql_read_default_file=$dbconfig",undef,undef)
                	or die "Couldn't connect to database: " . DBI->errstr;
	        
		$sql=$dbh->prepare("SELECT id, chr, v_start, v_end, reference, genotype from _UnifiedCalls $aux")
			or die "Couldn't prepare statement: " . $dbh->errstr;
		
		$sql->execute()
                	or die "Couldn't execute statement: " . $sql->errstr;

	# Use the user input
	
		my $is_colocated=defined $check_alleles? 0 : 1;
	# read Variations entries
	
	 	while (@sql_out = $sql->fetchrow_array()){
		####################################
		########## PRE PROCESS #############
		####################################
		#id, sample_id, chr, v_start, v_end, genotype, reference
			my ($uid,$chr,$g_start,$g_end,$ref_dna,$mut_dna)=@sql_out;
			print "chr:$chr\tstart:$g_start\tend:$g_end\tref:$ref_dna\tmut:$mut_dna\n" if $DEBUG;
			$chr=~s/chr//;
		#warn "alternative allele($mut_dna) is not one of ATGC\nchr$chr\t$g_start\t$g_end\t$ref_dna\t$mut_dna\n" unless $mut_dna=~/[ATGC-]/;

			my $allele_string="$ref_dna/$mut_dna";  # the first allele should be the reference allele
			my $slice = $slice_adaptor->fetch_by_region('chromosome', $chr); 

		# [QC] a slice should be defined by now. 
			if($DEBUG){
				my $slice = $slice_adaptor->fetch_by_region('chromosome', $chr);
				die "no slice chr:$chr\tg_start:$g_start\n" unless defined $slice;
				print "\e[33mOn Slice:\e[0m ",$slice->name, "\tChr:", $slice->seq_region_name, "\tStrand: ", $slice->strand,"\t[WT]:$ref_dna\t[MUT]:$mut_dna\n";
			}		
			warn "no slice chr:$chr\tg_start:$g_start\n" and next unless defined $slice;

		# a new VariationFeature object
		# http://www.ensembl.org/info/docs/api/variation/variation_tutorial.html
		# create a new VariationFeature object, which is the position of a Variation object on the Genome
			my $new_vf = Bio::EnsEMBL::Variation::VariationFeature->new(
				-start => $g_start,
				-end => $g_end,
				-slice => $slice,           # the variation must be attached to a slice
				-allele_string => "$allele_string",    # the first allele should be the reference allele
				-strand => $slice->strand, # 1 by default
				-map_weight => 1,
				-adaptor => $vfa,           # we must attach a variation feature adaptor (defined globally)
				#-variation_name=> 
			);

			my($ref_dbsnp,$ref_clinvar,$ref_hgmd,$ref_cosmic,$ref_esp)=&find_existing($new_vf); 

			# db id: 1
			foreach (@{$ref_dbsnp}){
				print "0\t$uid\t1\t$_\t$is_colocated\t\n";
			}	
			# db id: 32 
			foreach (@{$ref_clinvar}){
				print "0\t$uid\t32\t$_\t$is_colocated\n";
			}
			# db id: 8 
			foreach (@{$ref_hgmd}){
				print "0\t$uid\t8\t$_\t$is_colocated\n";
			}
			# db id: 26 
			foreach (@{$ref_cosmic}){
				print "0\t$uid\t26\t$_\t$is_colocated\n";
			}
			# db id: 7 
			foreach (@{$ref_esp}){
				print "0\t$uid\t7\t$_\t$is_colocated\n";
			}

			# db id: 0 (hgmd_pro) 
			# SQL/update_HasFound.hgmd_pro.sql

			# db id: 00 (ICC_Mutation) ?? 

		}#end of foreach $sql result 
	}else{
                &help() and exit(0) unless $start and $end and $allele;
                my($ref,$genotype)=split(/\//,$allele);
                my $dummy_uid=0;
		while (@sql_out = $sql->fetchrow_array()){
                	push @sql_out, "$dummy_uid\t$region\t$start\t$end\t$ref\t$genotype";
		}
        }
	$sql->finish();
	$dbh->disconnect();	
}#end of MAIN

#copied from /data/Install/Perl/ensembl-variation/modules/Bio/EnsEMBL/Variation/Utils/VEP.pm
sub find_existing{
	my $new_vf=shift;

    if(defined($new_vf->adaptor->db)) {
        my $sth = $new_vf->adaptor->db->dbc->prepare(qq{
            SELECT variation_name, source_id, seq_region_start, seq_region_end, allele_string, seq_region_strand
            FROM variation_feature
            WHERE seq_region_id = ?
            AND seq_region_start = ?
            AND seq_region_end = ?
            ORDER BY source_id ASC
        });

        
        $sth->execute($new_vf->slice->get_seq_region_id, $new_vf->start, $new_vf->end);
        
        my @v;
        for my $i(0..5) {
            $v[$i] = undef;
        }
        
        $sth->bind_columns(\$v[0], \$v[1], \$v[2], \$v[3], \$v[4], \$v[5]);

        my @rs_ids;
        my @clinvars;
        my @hgmds;
        my @cosmics;
        my @esps;
        
        while($sth->fetch) {
			#push @found, $v[0] unless is_var_novel(\@v, $new_vf);
            unless (is_var_novel(\@v, $new_vf)){
				push @rs_ids, $v[0] if $v[1]==1; #dbSNP(1);
				push @clinvars, $v[0] if $v[1]==32; #dbSNP_ClinVar(32); 
				push @hgmds, $v[0] if $v[1]==8; #HGMD-PUBLIC;
				push @cosmics, $v[0] if $v[1]==26; #COSMIC;
				push @esps, $v[0] if $v[1]==7; #ESP;
			}	
        }
        
        $sth->finish();
        
		#return (scalar @found ? join ",", @found : undef);

		# flatten a list to a string
=flatten
		my $rs_ids= (scalar @rs_ids ? join (',', @rs_ids) : '\\N');
		my $hgmds = (scalar @hgmds ? join (',', @hgmds) : '\\N');
		my $cosmics= (scalar @cosmics ? join (',', @cosmics) : '\\N');
		my $esps= (scalar @esps? join (',', @esps) : '\\N');
=cut
		return (\@rs_ids,\@clinvars,\@hgmds,\@cosmics,\@esps);
    }
    
    return undef;
}

#copied from /data/Install/Perl/ensembl-variation/modules/Bio/EnsEMBL/Variation/Utils/VEP.pm
# compare a new vf to one from the cache / DB
sub is_var_novel {
    my $existing_var = shift;
    my $new_var = shift;
    
    my $is_novel = 1;
    
	# co-located
    $is_novel = 0 if $existing_var->[2] == $new_var->start && $existing_var->[3] == $new_var->end;
    
    if(defined($check_alleles)) {
        my %existing_alleles;
        
		# allele_string
        $existing_alleles{$_} = 1 for split /\//, $existing_var->[4];
        
        my $seen_new = 0;
        foreach my $a(split /\//, $new_var->allele_string) {
            reverse_comp(\$a) if $new_var->strand ne $existing_var->[5];
            $seen_new = 1 unless defined $existing_alleles{$a};
        }
        
        $is_novel = 1 if $seen_new;
    }
    
	# if HGMD-PUBLIC, force it to be novel as there aren't any allele_string for this
	$is_novel = 0 if $existing_var->[1]==8; 
    return $is_novel;
}


sub help{
	my $usage =<<END;
[USAGE] perl $0 
	--sql # using the table _UnifeidCalls (or not) to get the data (default: not using the table)
	--db # Database to use (e.g. CARDIODB_DEVEL (default) or NECTAR)
	--chr # chromosime number (e.g. 1, 2, X, Y, MT)
	--start # start position of an allele (e.g. 1234)
	--end # end position of an allele (e.g. 1234)
	--allele # allele string (e.g. A/T)
	--all # run all entries in _UnifiedCalls 
	--not_found_only # run for _UnifiecCalls.has_found=0
	--new_entries # run for _UnifiedCalls.is_new=1
##############################		
# example 
##############################		
	1. SQL (using CARDIODB._UnifiedCalls)
		perl $0 --sql --db CARDIODB_DEVEL --all : run for all chromosome without checking allele type
		perl $0 --sql --db CARDIODB_DEVEL --all --check_alleles : run for all chromosome and check allele type
		perl $0 --sql --db CARDIODB_DEVEL --not_found_only --check_alleles : run for _UnifiedCalls.has_found=0
		perl $0 --sql --db CARDIODB_DEVEL --new_entries --check_alleles : run for _UnifiedCalls.is_new=1
		perl $0 --sql --db CARDIODB_DEVEL --chr 1 : run only for chromosome 1

	2. Non-SQL (from user input)
		perl $0 --chr 1 --start 6267531 --end 6267531 --allele C/T  --check_alleles
\e[0m
END
	warn "\e[032m$usage\e[0m";
}

