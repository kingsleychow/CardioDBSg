#===============================================================================
#
#         FILE:  HGVS.pm
#
#  DESCRIPTION:  To parse HGV format (http://www.hgvs.org/mutnomen/) 
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Sungsam Gong (sung), sung@bio.cc
#      COMPANY:  Royal Brompton and Harefield NHS Trust
#      VERSION:  1.0
#      CREATED:  11/09/2011 11:41:14 AM
#     REVISION:  ---
#===============================================================================
package Sung::Parser::HGVS;
use Moose;
use namespace::autoclean;
use MooseX::StrictConstructor;

use lib '/data/Develop/Perl/lib';
use Sung::Data::MyTypes qw/MutType/; # within Sung::Data::MyTypes::Bio::Variants
extends 'Sung::Parser';

# extends, roles, attributes, etc.
has allele=>(
	is=>'ro',
	isa=>'Str',
	required => 1,
);
#has mut_type =>(
#	is=>'rw',
#	isa=>enum([qw/SNP Ins Del CompIns CompDel Comp/]),
#);
has mut_type =>(
	is=>'rw',
	isa=>MutType,
);
has [qw/start end/]=>(
	is=>'rw',
	isa=>'Int',
);
has [qw/reference genotype/]=>(
	is=>'rw',
	isa=>'Str',
);

# to deal with non-hashref construction (e.g. ->new($string) ->new(allele=>$string))
around BUILDARGS => sub {
	my $orig  = shift;
	my $class = shift;

	if ( @_ == 1 && !ref $_[0] ) {
		return $class->$orig( allele=> $_[0] );
	}else{
		return $class->$orig(@_);
	}
};

sub BUILD{
	my $self=shift;

	my $allele=$self->allele;
	die "No input to parse\n" if $allele=~/^$/;

	#c.4433A>G
	#c.827TG>GT
	#c.2395C>T?
	#c.34G>A/C
	#c.(1873C>T)
	#c.*1659C>T
	if($allele=~/^c\.\(?\*?(\d+)([ATGCatgc]+)>([ATGCatgc\/]+)\??\)?$/){
		$self->start($1);
		$self->reference($2);
		$self->end($self->start+length($self->reference)-1);
		$self->genotype($3);
		$self->mut_type('SNP');
	#c.938_939TC>AA
	}elsif($allele=~/^c\.(\d+)_(\d+)([ATGCatgc]+)>([ATGCatgc]+)$/){
		$self->start($1);
		$self->end($2);
		$self->reference($3);
		$self->genotype($4);
		$self->mut_type('SNP');
	#c.107_108insT
	#c.107645_107655insTGAAAGAAAAA ??
	}elsif($allele=~/^c\.(\d+)_(\d+)ins([ATGCatgc]+)$/){
		$self->start($1 + 1);
		$self->end($1);
		$self->genotype($3);
		$self->mut_type('Ins');
	#c.983_984ins
	#c.5385_5386ins?
	}elsif($allele=~/^c\.(\d+)_(\d+)ins\??$/){
		$self->start($1 + 1);
		$self->end($1);
		$self->mut_type('Ins');
	#c.13insT
	}elsif($allele=~/^c\.(\d+)ins([ATGC])$/){
		$self->start($1 + 1);
		$self->end($1);
		$self->genotype($2);
		$self->mut_type('Ins');
	#c.2686_2687dupGA
	}elsif($allele=~/^c\.(\d+)_(\d+)dup([ATGCatgc]+)$/){
		$self->start($2 + 1);
		$self->end($2);
		$self->genotype($3);
		$self->mut_type('Ins');
	#c.1211dupT
	}elsif($allele=~/^c\.(\d+)dup([ATGCatgc]+)$/){
		$self->start($1 + 1);
		$self->end($1);
		$self->genotype($2);
		$self->mut_type('Ins');
	#c.1231dup
	#c.411dup8
	}elsif($allele=~/^c\.(\d+)dup\d*$/){
		$self->start($1 + 1);
		$self->end($1);
		$self->mut_type('Ins');
	#c.7908_7911dup
	#c.(348_352dup)
	}elsif($allele=~/^c\.\(?(\d+)_(\d+)dup\)?$/){
		$self->start($2 + 1);
		$self->end($2);
		$self->mut_type('Ins');
	#c.8759_8760ins218
	}elsif($allele=~/^c\.(\d+)_(\d+)ins\d*$/){
		$self->start($1 + 1);
		$self->end($1);
		$self->mut_type('Ins');
	#c.987del
	#c.321delT
	#c.771delG?
	#c.(4638delA)
	}elsif($allele=~/^c\.\(?(\d+)del([ATGC]*)\??\)?$/){
		$self->start($1);
		$self->end($1);
		$self->reference(defined $2? $2: undef);
		$self->mut_type('Del');
	#c.929_930del
	#c.603_605delTGA
	#c.(8198_8199del)
	}elsif($allele=~/^c\.\(?(\d+)_(\d+)del([ATGC]*)\)?$/){
		$self->start($1);
		$self->end($2);
		$self->reference(defined $3? $3: undef);
		$self->mut_type('Del');
	#c.1124_1127TTCA
	}elsif($allele=~/^c\.(\d+)_(\d+)([ATGC]+)$/){
		$self->start($1);
		$self->end($2);
		$self->reference($3);
		$self->mut_type('Del');
	#c.484_486?
	}elsif($allele=~/^c\.(\d+)_(\d+)\?$/){
		$self->start($1);
		$self->end($2);
		$self->mut_type('Del');
	#c.2742_2775del34bp
	}elsif($allele=~/^c\.(\d+)_(\d+)del\d+bp$/){
		$self->start($1);
		$self->end($2);
		$self->mut_type('Del');
	#c.227_229delACCinsTCTA
	}elsif($allele=~/^c\.(\d+)_(\d+)del([ATGC]+)ins([ATGC]+)$/){
		$self->start($1);
		$self->end($2);
		$self->reference($3);
		$self->genotype($4);
		$self->mut_type('Comp');
	#c.10223+3del
	}elsif($allele=~/^c\.\(?(\d+)[+-]\d+del([ATGC]*)\??\)?$/){
		$self->mut_type('Del');
	#c.*23_*35del
	#c.748-?_956+?del
	}elsif($allele=~/^c\.(\d+)[+-]?\??\d*_(\d+)[+-]?\??\d*del$/){
		$self->mut_type('Del');
	#c.1684_1685delAG+1delG
	}elsif($allele=~/^c\.(\d+)[+-]?\d*_(\d+)[+-]?\d*del[ATGC]*[+-]?\d*(del)?[ATGC]*$/){
		$self->mut_type('Comp');
	#c.1631-1632delAG
	#c.631-13dupA
	}elsif($allele=~/^c\.(\d+)[+-]\d+(del|dup)([ATGCatgc]+)$/){
		$self->mut_type('Comp');
	#c.4780delTins37
	}elsif($allele=~/^c\.(\d+)del([ATGCatgc])ins\d+$/){
		$self->start($1);
		$self->reference($2);
		$self->mut_type('Comp');
	#c.888delGinsAA
	#c.533delCinsGG
	#c.3252delC+3263insC
	}elsif($allele=~/^c\.(\d+)del([ATGCatgc]+)ins([ATGCatgc]+)$/){
		$self->start($1);
		$self->reference($2);
		$self->genotype($3);
		$self->end($self->start($1) + length($self->reference($2)) - 1);
		$self->mut_type('Comp');
	#c.4299+1insG
	}elsif($allele=~/^c\.(\d+)[+-]\d+ins([ATGCatgc])$/){
		$self->mut_type('Ins');
	#c.8174_8184dup8184_8185insTAGAAGGCTCCTAG
	}elsif($allele=~/^c\.(\d+)_(\d+)dup\d+_\d+ins[ATGC]+$/){
		$self->mut_type('Comp');
	#c.3246_3247insTins3238_3246
	}elsif($allele=~/^c\.(\d+)[+-]?\d*_(\d+)[+-]?\d*ins[ATGC]ins\d+_\d+$/){
		$self->mut_type('Comp');
	#c.40087+3TA(11_15)
	}elsif($allele=~/^c\.(\d+)[+-]\d+[ATGC]+\(\d+_\d+\)$/){
		$self->mut_type('Comp');
	#c.187-13_194inv
	#c.266_267inv
	}elsif($allele=~/^c\.\d+[+-]?\d*_\d+[+-]?\d*inv$/){
		$self->mut_type('Comp');
	#c.1129-2A>G : skip this...
	#c.1557+1G>C
	#c.1331+1G>A
	}elsif($allele=~/^c\.(\d+)([-+])(\d+)([ATGCatgc])>([ATGCatgc])$/){
		$self->reference($4);
		$self->genotype($5);
		$self->mut_type('SNP');
	#c.1945?
	#c.744G>?
	#c.1013T>
	#c.5325+?
	}elsif($allele=~/^c.(\d+)[ATGC]*>?[+-]?\??$/){
		$self->mut_type('SNP');
	#c.611+3_611+4insAA
	#c.2169-615_2292+1354dupinsCTGT
	#c.9657_9658ins312insTTC
	#c.2692_2962+1insACACGG
	#:c.483-10_492delTCCTGCCCAGGTACACCTTC
	}elsif($allele=~/^c\.(\d+)[+-]?\d*_(\d+)[+-]?\d*(dup|ins|del)?\d*(ins|del)[ATGC]*\d*\??$/){
		$self->mut_type('Comp');
	}else{
		$self->mut_type('Comp');
		warn "parse this:$allele\n";
	}
	$self->reference(uc $self->reference) if $self->reference; 
	$self->genotype(uc $self->genotype) if $self->genotype;
}

__PACKAGE__->meta->make_immutable;
1;


