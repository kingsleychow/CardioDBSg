#!/usr/bin/perl -w
=header1
last modified
10/Dec/2012
Sung Gong <sung.gong@yahoo.com>
=cut

use strict;
use Getopt::Long;
use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Sequence qw(reverse_comp);
use lib '/data/Develop/Perl/lib';
use Sung::Manager::Config;

my $DEBUG=0; #
my $CARDIODB='CARDIODB_DEVEL';

# Get DB config
my $db_config='/data/Develop/Perl/lib/Sung/Manager/Config/db.conf';
my $config=Sung::Manager::Config->get_config_from_file($db_config);
my $host=$config->{db}{host};
my $cardiodb=$config->{db}{cardiodb};
my $nectar=$config->{db}{nectar};
my $user=$config->{db}{user};
my $passwd=$config->{db}{passwd};
my $CARDIODB_ROOT=$config->{CARDIODB_ROOT};
my $NECTAR_ROOT=$config->{NECTAR_ROOT};

my ($is_sql,$which_db,$all,$region,$start,$end,$allele,$check_alleles,$not_in_v2ensembl,$new_entries,$canon_only,$v2ensx,$annotation,$help);
GetOptions
(
	'sql' => \$is_sql,
	'db:s' => \$which_db,
	'all:s' => \$all,  # a flag
    'chr:s'	=>	\$region, #optional
	'start=i'=> \$start,
	'end=i'=> \$end,
	'allele=s'=> \$allele,
	'check_alleles' => \$check_alleles,
	'not_in_v2ensembl' => \$not_in_v2ensembl,
	'new_entries' => \$new_entries,
	'canon_only' =>  \$canon_only,
	'v2ensx' => \$v2ensx,
	'annotation' => \$annotation,
	'help!' => \$help,
);

&help and exit(0) if $help;
if(defined $region){&help and exit(0) unless $region=~m/^(1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|X|Y|MT)$/};

#############################################################
## Get DB connection to ENSEMBL #############################
## local ensembl registry: ~/.ensembl_api.conf ##############
#############################################################
my $reg = "Bio::EnsEMBL::Registry";
$reg->load_all(); # from ENSEMBL_RETISTRY (check $ENSEMBL_RERISTRY env)
my $slice_adaptor=$reg->get_adaptor('human','core','slice');
#my $slice_adaptor=$reg->get_adaptor("Slice"); #my $slice_adaptor=$reg->get_adaptor("Human", "core", "slice");
#my $slice_adaptor=$reg->get_SliceAdaptor();
die "Can't get the slice adaptor\n" unless defined $slice_adaptor;
my $cs_adaptor = $reg->get_adaptor( 'Human', 'Core', 'CoordSystem' );
die "Can't get the CoordSystem adaptor\n" unless defined $cs_adaptor;

my $cs = $cs_adaptor->fetch_by_name('chromosome');
printf "Coordinate system: %s %s\n", $cs->name(), $cs->version() if $DEBUG; 

my $va= $reg->get_adaptor('human','variation','variation');
die "cannot get Variation adaptor\n" unless defined $va;

my $vfa= $reg->get_adaptor('human','variation','variationfeature');
die "cannot get VariationFeature adaptor\n" unless defined $vfa;

my $ga= $reg->get_adaptor('Human', 'core', 'gene');
my $tla= $reg->get_adaptor('Human', 'core', 'translation');


MAIN:{
	my @results;
	# Using SQL to search against _UnifiedCalls table
	if(defined $is_sql){
		&help() and exit(0) unless defined $all or $region;
		#my $aux= defined $all? '' : $region? "where chr='chr$region'" : ''; #14/Jan/2013
		my $aux= $region? "where chr='chr$region'" : '';
		$aux=$not_in_v2ensembl? 
			$aux=~/where/? $aux.' and in_ensembl=0': 'where in_ensembl=0'
			:$aux;
		$aux=$new_entries? 
			$aux=~/where/? $aux.' and is_new=1': 'where is_new=1'
			:$aux;
		my $db=$which_db eq $cardiodb? $cardiodb : $which_db eq $nectar? $nectar : $which_db;

		my $query= "SELECT id, chr, v_start, v_end, reference, genotype from $db._UnifiedCalls $aux"; # from _UnifiedCallers
		print $query,"\n";

		my $sql=`mysql -h $host -u $user -p$passwd $CARDIODB --skip-column-name -e "$query"`;
		die "No entries in _UnifiedCalls\n" unless defined $sql;
		@results=split(/\n/,$sql);

		### Make File Handle ###
		my ($v2ens,$v2dbsnp,$v2phen,$v2freq);
		#my $name= defined $not_in_v2ensembl? 'added' : $all? 'all': $region? 'chr'.$region : ''; #14/Jan/2013
		my $name=''; 
		$name=$name.'chr'.$region if $region;
		$name=$name.'all' if defined $all;
		$name=$name.'.canon_only' if defined $canon_only;
		$name=$name.'.added' if $not_in_v2ensembl or $new_entries;

		my $dump_root=$which_db eq $cardiodb? $CARDIODB_ROOT : $which_db eq $nectar? $NECTAR_ROOT : '' ;
		
		$v2ens=$dump_root.'/Dump/V2Ensembls/V2Ensembls.'.$name.'.txt';
		open (ENS, "+>$v2ens") or die "cannot make $v2ens :$!\n";
		if($annotation){
			# V2dbSNPs.all.txt (--all)
			# V2dbSNPs.chr1.txt (--chr)
			# V2dbSNPs.added.txt (--not-in-v2ensembl)
			$v2dbsnp=$dump_root.'/Dump/V2dbSNPs/V2dbSNPs.'.$name.'.txt';
			$v2phen= $dump_root.'/Dump/V2Phens/V2Phens.'.$name.'.txt';
			$v2freq= $dump_root.'/Dump/V2Freqs/V2Freqs.'.$name.'.txt';
			open (DBS, "+>$v2dbsnp") or die "cannot make $v2dbsnp :$!\n";
			open (PHEN, "+>$v2phen") or die "cannot make $v2phen :$!\n";
			open (FRE, "+>$v2freq") or die "cannot make $v2freq :$!\n";
		}

	# Use the user input
	}else{
		&help() and exit(0) unless $start and $end and $allele;
		my($ref,$genotype)=split(/\//,$allele);
		my $dummy_uid=0;
		push @results, "$dummy_uid\t$region\t$start\t$end\t$ref\t$genotype";
	}

	# read Variations entries
	foreach (@results){
		####################################
		########## PRE PROCESS #############
		####################################
		#id, sample_id, chr, v_start, v_end, genotype, reference
		my ($uid,$chr,$g_start,$g_end,$ref_dna,$mut_dna)=split(/\t/,$_);
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

		################################################
		########## Ensembl API runs (ENSX) #############
		################################################
		## NO GENE SLICE (possible UPSTREAM, REGULATORY or INTERGENIC) 
		&v2ensx($uid,$new_vf,$chr,$g_start,$g_end,$ref_dna,$mut_dna) if $v2ensx;
		&v2dbsnp($uid,$new_vf) if $annotation;
	}#end of foreach $sql result 
	close ENS;
	close DBS and close PHEN  and close FRE if $annotation;
}#end of MAIN

sub v2ensx{
	my($uid,$new_vf,$chr,$g_start,$g_end,$ref_dna,$mut_dna)=@_;

	# new function
	my($rs_ids,$hgmds,$cosmics,$esps)=&find_existing($new_vf); 
	# old function
	#&find_co_located_variants($new_vf,$g_start,$g_end);

	######################################################################################################################
	# 1. Get TranscriptVariation from VarationFeature
	# 'get_all_TranscriptVariations' returns listref of Bio::EnsEMBL::Variation::TranscriptVariation
	# A TranscriptVariation object represents a variation feature which is in close proximity to an Ensembl transcript. 
	######################################################################################################################
	# No TranscriptVariation - possible no GENE object within the slice (possible UPSTREAM, REGULATORY or INTERGENIC) 
	# initialise values to print out
	my ($cdna_start,$cdna_end,$cds_start,$cds_end)=qw/0 0 0 0/;
	my ($enst,$is_canonical,$tr_biotype,$ccds,$strand,$gene_biotype,$ensg,$ensp,$hgnc,$codons,$tl_start,$tl_end,$pep_ref,$pep_mut) =('\\N','\N','\\N','\\N','\\N','\\N','\\N','\\N','\\N','\\N','\\N','\\N','\\N','\\N');
	my ($sift,$sift_score,$pph_var,$pph_var_score,$pph_div,$pph_div_score)=('\\N','\\N','\\N','\\N','\\N','\\N');
	my ($tr_allele,$hgvs_transcript, $hgvs_protein)=('\\N', '\\N', '\\N');
	my $so_terms='intergenic_variant'; #default Consequence Type
	unless(@{$new_vf->get_all_TranscriptVariations}){
		unless($canon_only){
			warn "\e[33mNo TranscriptVariation object found\e[0m\n";
			#$ct=$new_vf->consequence_type('display')? join (',', @{$new_vf->consequence_type('display')}):'INTERGENIC';
			$so_terms= $new_vf->consequence_type('SO')? join (',', @{$new_vf->consequence_type('SO')}):'intergenic_variant';

			# Get possible gene object using new slice adaptor based on the genomic region (NB, $g_start, $g_end defined here)
			my $my_slice = $slice_adaptor->fetch_by_region('chromosome', $chr, $g_start, $g_end); 
			foreach my $gene ( @{ $my_slice->get_all_Genes } ) {
				# get ENSG
				$ensg = $gene->stable_id? $gene->stable_id:'\N';
				$strand= $gene->strand? $gene->strand:'\N';
				$gene_biotype= $gene->biotype? $gene->biotype:'\N';

				# get HGNC
				my @entries = grep {$_->database eq 'HGNC'} @{$gene->get_all_DBEntries()};
				$hgnc= (scalar @entries ? $entries[0]->display_id : '\\N'); # get the first entry name

				if($is_sql){
					print ENS "0\t$uid\t",
					"$strand\t$ensg\t$hgnc\t$gene_biotype\t",
					"$enst\t$is_canonical\t$tr_biotype\t$cdna_start\t$cdna_end\t$cds_start\t$cds_end\t$codons\t$tr_allele\t$hgvs_transcript\t$ccds\t$so_terms\t$rs_ids\t$hgmds\t$cosmics\t",
					"$ensp\t$tl_start\t$tl_end\t$pep_ref\t$pep_mut\t$hgvs_protein\t$sift\t$sift_score\t$pph_var\t$pph_var_score\t$pph_div\t$pph_div_score\n" unless $DEBUG;
				}else{
					print "0\t$uid\t",
					"$strand\t$ensg\t$hgnc\t$gene_biotype\t",
					"$enst\t$is_canonical\t$tr_biotype\t$cdna_start\t$cdna_end\t$cds_start\t$cds_end\t$codons\t$tr_allele\t$hgvs_transcript\t$ccds\t$so_terms\t$rs_ids\t$hgmds\t$cosmics\t",
					"$ensp\t$tl_start\t$tl_end\t$pep_ref\t$pep_mut\t$hgvs_protein\t$sift\t$sift_score\t$pph_var\t$pph_var_score\t$pph_div\t$pph_div_score\n" unless $DEBUG;
				}
			}
		}
	# There is a TranscriptVariation
	}else{
		foreach my $tr_v(@{$new_vf->get_all_TranscriptVariations}) {
			#$ct=$new_vf->consequence_type('display')? join (',', @{$new_vf->consequence_type('display')}):'INTERGENIC';
			$so_terms=$tr_v->consequence_type('SO')? join (',', @{$tr_v->consequence_type('SO')}):'intergenic_variant';

			my $tr=$tr_v->transcript;

			# No Transcript defined for a given genomic region
			unless(defined $tr){
				unless($canon_only){
					warn "\e[33mNo transcript object found\e[0m\n";

					# Get possible gene object using new slice adaptor based on the genomic region (NB, $g_start, $g_end defined here)
					my $my_slice = $slice_adaptor->fetch_by_region('chromosome', $chr, $g_start, $g_end); 
					foreach my $gene ( @{ $my_slice->get_all_Genes } ) {
						# get ENSG
						$ensg = $gene->stable_id? $gene->stable_id:'\N';
						$strand= $gene->strand? $gene->strand:'\N';
						$gene_biotype= $gene->biotype? $gene->biotype:'\N';

						# get HGNC
						my @entries = grep {$_->database eq 'HGNC'} @{$gene->get_all_DBEntries()};
						$hgnc= (scalar @entries ? $entries[0]->display_id : '\\N'); # get the first entry name

						if($is_sql){
							print ENS "0\t$uid\t",
							"$strand\t$ensg\t$hgnc\t$gene_biotype\t",
							"$enst\t$is_canonical\t$tr_biotype\t$cdna_start\t$cdna_end\t$cds_start\t$cds_end\t$codons\t$tr_allele\t$hgvs_transcript\t$ccds\t$so_terms\t$rs_ids\t$hgmds\t$cosmics\t",
							"$ensp\t$tl_start\t$tl_end\t$pep_ref\t$pep_mut\t$hgvs_protein\t$sift\t$sift_score\t$pph_var\t$pph_var_score\t$pph_div\t$pph_div_score\n" unless $DEBUG;
						}else{
							print "0\t$uid\t",
							"$strand\t$ensg\t$hgnc\t$gene_biotype\t",
							"$enst\t$is_canonical\t$tr_biotype\t$cdna_start\t$cdna_end\t$cds_start\t$cds_end\t$codons\t$tr_allele\t$hgvs_transcript\t$ccds\t$so_terms\t$rs_ids\t$hgmds\t$cosmics\t",
							"$ensp\t$tl_start\t$tl_end\t$pep_ref\t$pep_mut\t$hgvs_protein\t$sift\t$sift_score\t$pph_var\t$pph_var_score\t$pph_div\t$pph_div_score\n" unless $DEBUG;
						}
					}#end of foreach my $gene
				}
			# OK, there are Transcript object!
			}else{
				#ENST
				$enst = $tr->stable_id ? $tr->stable_id:'\N';
				$is_canonical= defined $tr->is_canonical ? $tr->is_canonical:'\N';
				next if $canon_only and $is_canonical==0;

				$tr_biotype= $tr->biotype ? $tr->biotype:'\N';

				#ENSG
				my $gene= $ga->fetch_by_transcript_stable_id($enst);
				$strand= $gene->strand ? $gene->strand :'\N';
				$ensg = $gene->stable_id ? $gene->stable_id:'\N';
				$gene_biotype= $gene->biotype ? $gene->biotype:'\N';

				#ENSP
				my $tl = $tla->fetch_by_Transcript($tr);
				$ensp = $tl ? $tl->stable_id:'\N';

				#HGNC
				my @entries = grep {$_->database eq 'HGNC'} @{$gene->get_all_DBEntries()};
				$hgnc= (scalar @entries ? $entries[0]->display_id : '\\N');

				#CCDS
				$ccds= @{$tr->get_all_DBEntries('CCDS')}? join(",",map {$_->primary_id()} @{$tr->get_all_DBEntries('CCDS')}):'\N';

				# CDNA/ConsequenceType
				$cdna_start = $tr_v->cdna_start ? $tr_v->cdna_start:0;
				$cdna_end= $tr_v->cdna_end ? $tr_v->cdna_end:0;

				# CDS
				$cds_start = $tr_v->cds_start ? $tr_v->cds_start:0;
				$cds_end= $tr_v->cds_end ? $tr_v->cds_end:0;

				# CODON
				$codons= $tr_v->codons ? $tr_v->codons:'\N';

				# Transcript Allele String
				$tr_allele=join("/", map { $_->feature_seq } @{ $tr_v->get_all_TranscriptVariationAlleles });

				# PEPALLELE
				$tl_start = $tr_v->translation_start ? $tr_v->translation_start:'\N';
				$tl_end = $tr_v->translation_end ? $tr_v->translation_end:'\N';
				if($tr_v->pep_allele_string){
					($pep_ref,$pep_mut)=split('/',$tr_v->pep_allele_string);
					$pep_mut=$pep_mut?$pep_mut:'\N';
				}else{
					($pep_ref,$pep_mut)=('\N','\N');
				}
				#($pep_ref,$pep_mut)=$tr_v->pep_allele_string ? split('/',$tr_v->pep_allele_string):('\N','\N');

				# get a list of the all the alternate allele from this TranscriptVariation (no reference)
				# A TranscriptVariationAllele object represents a single allele of a TranscriptVariation.
				my $tvas = $tr_v->get_all_alternate_TranscriptVariationAlleles();
				foreach (@{$tvas}){
					# HGVS CODING
					$hgvs_transcript=$_->hgvs_transcript ? $_->hgvs_transcript:'\\N';
					#my $hgvs_genomic=$_->hgvs_genomic ? $_->hgvs_genomic:'\\N';

					####################################################
					############ Mutation Effect Prediction ############
					####################################################
					# 1. SIFT
					$sift=$_->sift_prediction? $_->sift_prediction:'\\N' ;
					$sift_score=$_->sift_score? $_->sift_score:'\\N' ;
					# 2. Polyphen
					$pph_var=$_->polyphen_prediction? $_->polyphen_prediction:'\\N' ;
					$pph_var_score=$_->polyphen_score? $_->polyphen_score:'\\N' ;
					$pph_div=$_->polyphen_prediction('humdiv')? $_->polyphen_prediction('humdiv'):'\\N' ;
					$pph_div_score=$_->polyphen_score('humdiv')? $_->polyphen_score('humdiv'):'\\N' ;
					# 3. Condel
					#$condel=$_->condel_prediction? $_->condel_prediction:'\\N' ;
					#$condel_score=$_->condel_score? $_->condel_score:'\\N' ;
					# 4. HGVS PROTEIN
					$hgvs_protein=$_->hgvs_protein? $_->hgvs_protein:'\\N';

					if($is_sql){
						print ENS "0\t$uid\t",
						"$strand\t$ensg\t$hgnc\t$gene_biotype\t",
						"$enst\t$is_canonical\t$tr_biotype\t$cdna_start\t$cdna_end\t$cds_start\t$cds_end\t$codons\t$tr_allele\t$hgvs_transcript\t$ccds\t$so_terms\t$rs_ids\t$hgmds\t$cosmics\t",
						"$ensp\t$tl_start\t$tl_end\t$pep_ref\t$pep_mut\t$hgvs_protein\t$sift\t$sift_score\t$pph_var\t$pph_var_score\t$pph_div\t$pph_div_score\n" unless $DEBUG;
					}else{
						print "0\t$uid\t",
						"$strand\t$ensg\t$hgnc\t$gene_biotype\t",
						"$enst\t$is_canonical\t$tr_biotype\t$cdna_start\t$cdna_end\t$cds_start\t$cds_end\t$codons\t$tr_allele\t$hgvs_transcript\t$ccds\t$so_terms\t$rs_ids\t$hgmds\t$cosmics\t",
						"$ensp\t$tl_start\t$tl_end\t$pep_ref\t$pep_mut\t$hgvs_protein\t$sift\t$sift_score\t$pph_var\t$pph_var_score\t$pph_div\t$pph_div_score\n" unless $DEBUG;
					}
				}#end of foreach 
			} # end of unless $tr 
		} #end of foreach $tr_v ($new_vf->get_all_TranscriptVariations)
	}#end of unless(@{$new_vf->get_all_TranscriptVariations})
}#end of sub enst

sub v2dbsnp{
	my ($uid,$new_vf)=@_;
	my($rs_ids,$hgmds,$cosmics,$esps)=&find_existing($new_vf); 
    foreach my $rs_id(split /\,/, $rs_ids) {
		my $v=$va->fetch_by_name($rs_id);
		next unless $v;

		# basic info
		#my $class=$v->var_class? $v->var_class:'\N'; #eg. SNP...
		my $allele_string= $v->get_all_VariationFeatures->[0]->allele_string; # get only the first one
		my $am_code=$v->ambig_code? $v->ambig_code:'\N';
		my $minor_allele=$v->minor_allele? $v->minor_allele:'\N';
		my $ance=$v->ancestral_allele ? $v->ancestral_allele:'\\N';
		my $mac=$v->minor_allele_count? $v->minor_allele_count:'\N';
		my $maf=$v->minor_allele_count? $v->minor_allele_frequency:'\N';
		my $vstates= (scalar @{$v->get_all_validation_states()}? join (',', @{$v->get_all_validation_states()}) : '\N');
		my @cs=@{$v->get_all_clinical_significance_states()}? @{$v->get_all_clinical_significance_states()}:'\N';
		print DBS "0\t$uid\t$rs_id\t$allele_string\t$am_code\t$minor_allele\t$ance\t$mac\t$maf\t$vstates\t@cs\n";

		# Annotation
		## "get_all_VariationAnnotations" method changed into "get_all_PhenotypeFeatures" in Ensembl71 -- sjohn
		#foreach my $anno(@{$v->get_all_VariationAnnotations()}) {
		foreach my $anno(@{$v->get_all_PhenotypeFeatures()}) {
		#my $phen_name=$anno->phenotype_name? $anno->phenotype_name:'\N';
			my $phen_anno=$anno->phenotype? $anno->phenotype->description? $anno->phenotype->description:'\N' : '\N';
			my $exref=$anno->external_reference? $anno->external_reference:'\N';
			my $p_val=$anno->p_value? $anno->p_value: '\N';
			#my $risk_allele=$anno->associated_variant_risk_allele? $anno->associated_variant_risk_allele:'\N'; # depreciated since ver 71
			my $risk_allele=$anno->risk_allele? $anno->risk_allele:'\N';
			#my $source_name=$anno->source_name? $anno->source_name:'\N'; # deprecated since ver 71
			my $source_name=$anno->source? $anno->source:'\N'; 

			my $study_desc=$anno->study_description? $anno->study_description:'\N';
			#my $study_name=$anno->study_name? $anno->study_name:'\N'; # too sparse
			my $study_type=$anno->study? $anno->study->type? $anno->study->type:'\N' : '\N';
			#my $study_url=$anno->study_url? $anno->study_url:'\N'; # very sparse
			print PHEN "0\t$uid\t$rs_id\t$phen_anno\t$exref\t$p_val\t$risk_allele\t$source_name\t$study_desc\t$study_type\n";
		}

		# freqency
		foreach my $allele(@{$v->get_all_Alleles}) {
			next unless $allele->frequency;
			my $freq=$allele->frequency? $allele->frequency:'\\N';
			my $al=$allele->allele? $allele->allele:'\\N';
			my $pop_id=$allele->population? $allele->population->dbID:'\\N';
			#my $pop_des=$allele->population? $allele->population->'\\N';
			#my $population=$allele->population? $allele->population->name:'\\N';
			my $count=$allele->count? $allele->count:'\\N';

			print FRE "0\t$uid\t$rs_id\t$al\t$freq\t$count\t$pop_id\n";
		}
	}
}

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
        my @hgmds;
        my @cosmics;
        my @esps;
        
        while($sth->fetch) {
			#push @found, $v[0] unless is_var_novel(\@v, $new_vf);
            unless (is_var_novel(\@v, $new_vf)){
				push @rs_ids, $v[0] if $v[1]==1 or $v[1]==32; #dbSNP(1) or dbSNP_ClinVar(32); 
				push @hgmds, $v[0] if $v[1]==8; #HGMD-PUBLIC;
				push @cosmics, $v[0] if $v[1]==26; #COSMIC;
				push @esps, $v[0] if $v[1]==7; #ESP;
			}	
        }
        
        $sth->finish();
        
		#return (scalar @found ? join ",", @found : undef);

		# flatten a list to a string
		my $rs_ids= (scalar @rs_ids ? join (',', @rs_ids) : '\\N');
		my $hgmds = (scalar @hgmds ? join (',', @hgmds) : '\\N');
		my $cosmics= (scalar @cosmics ? join (',', @cosmics) : '\\N');
		my $esps= (scalar @esps? join (',', @esps) : '\\N');
		return ($rs_ids,$hgmds,$cosmics,$esps);
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
    
    return $is_novel;
}

sub find_co_located_variants{
	my ($new_vf,$g_start,$g_end)=@_;

	my (@rs_ids, @hgmds, @other_variants);
	######################################
	## find any co-located existing VFs ##
	######################################
	my $fs = $new_vf->feature_Slice;
	warn "\e[031mno feature_Slice\e[0m\n" unless $fs;

	# Probably insertion type - no sucha slice
	unless(@{$new_vf->adaptor->fetch_all_by_Slice($fs)}){
		warn "\e[031mno existing vf obj\e[0m\n";
	# Only for the non-insertion variation type
	}else{
		#my $rs_allele='\\N'; # allele string of co-colated rs_id
		foreach my $existing_vf_obj(@{$new_vf->adaptor->fetch_all_by_Slice($fs)}) {
			if ($existing_vf_obj->seq_region_start == $g_start and $existing_vf_obj->seq_region_end == $g_end){
				my $known_variation_name = $existing_vf_obj->variation_name;
				next unless $known_variation_name;

				my $v_source=$existing_vf_obj->variation()->source();
				if ($v_source=~ m/dbSNP/){
					push @rs_ids, $known_variation_name;	
					#push @rs_ids, map {$_} @{$existing_vf_obj->variation->get_all_synonyms('dbSNP')};

=rs_allele
					# fetch allele string of a given rs_id
					my $v = $va->fetch_by_name($known_variation_name);
					foreach my $vf (@{$vfa->fetch_all_by_Variation($v)}) {
						$rs_allele=$vf->allele_string? $vf->allele_string:'\\N';
					}
=cut
				}elsif($v_source=~m/HGMD/){
					push @hgmds, $known_variation_name;	
					#push @hgmds, map {$_} @{$existing_vf_obj->variation->get_all_synonyms('HGMD-PUBLIC')};
				}else{
					push @other_variants, $known_variation_name;	
					## Add synonym from varation_synonym
					push @other_variants, map {$_} @{$existing_vf_obj->variation->get_all_synonyms($v_source)};
				}

			}
		}
	}
	# flatten a list to a string
	my $rs_ids= (scalar @rs_ids ? join (',', @rs_ids) : '\\N');
	my $hgmds = (scalar @hgmds ? join (',', @hgmds) : '\\N');
	#my $other_variants= (scalar @other_variants ? join (',', @other_variants) : '\\N');
	return ($rs_ids,$hgmds);
}


sub help{
	my $usage =<<END;
[USAGE] perl $0 
	--sql # using the table CARDIODB._UnifeidCalls (or not) to get the data (default: not using the table)
	--db # Database to use (e.g. CARDIODB_DEVEL (default) or NECTAR)
	--chr # chromosime number (e.g. 1, 2, X, Y, MT)
	--start # start position of an allele (e.g. 1234)
	--end # end position of an allele (e.g. 1234)
	--allele # allele string (e.g. A/T)
	--v2ensx# main controller to print out variants mapped on ensembl
	--annotation # get annotations (this makes V2dbSNPs.txt, V2Phen.txt and V2Freq.txt)
##############################		
# example 
##############################		
	1. SQL (using CARDIODB._UnifiedCalls)
		perl $0 --sql --db CARDIODB_DEVEL --all --v2ensx: run for all chromosome
		perl $0 --sql --db CARDIODB_DEVEL --all --not_in_v2ensembl --v2ensx: run for all chromosome where variations not in V2Ensembl table
		perl $0 --sql --db CARDIODB_DEVEL --all --v2ensx --annotation: run for all chromosome and create annotation files  
		perl $0 --sql --db CARDIODB_DEVEL --all --annotation: only for annotations
		perl $0 --sql --db CARDIODB_DEVEL --chr 1 --v2ensx : run only for chromosome 1
		perl $0 --sql --db CARDIODB_DEVEL --chr 1 --not_in_v2ensembl --v2ensx : run only for chromosome 1 not within V2Ensembl table
		perl $0 --sql --db CARDIODB_DEVEL --chr 1 --not_in_v2ensembl --v2ensx --annotation: run only for chromosome 1 not within V2Ensembl table with annotations 

	2. Non-SQL (from user input)
		perl $0 --chr 1 --start 6267531 --end 6267531 --allele C/T --v2ensx
		perl $0 --chr 1 --start 6267531 --end 6267531 --allele C/T --v2ensx --canon_only
\e[0m
END
	warn "\e[032m$usage\e[0m";
}


