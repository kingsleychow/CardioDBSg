#
#===============================================================================
#
#         FILE:  UniRef.pm
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Sungsam Gong (sung), sung@bio.cc
#      COMPANY:  Royal Brompton and Harefield NHS Trust
#      VERSION:  1.0
#      CREATED:  27/10/11 14:18:48
#     REVISION:  ---
#===============================================================================
package Sung::Parser::UniProt::XML::UniRef;
use Moose;
use namespace::autoclean;
use lib '/data/Develop/Perl/lib';
#push @INC, '../../../Data/MyTypes';
use Sung::Data::MyTypes qw/File Dir/;
use MooseX::StrictConstructor;
use MooseX::Params::Validate;

use XML::Twig;

# extends, roles, attributes, etc.
# extends qw/Sung::Parser/; # chop house-keeping snippets out and move into parents?

has 'input'=>(
	is =>'ro',
	isa =>File, #MooseX::Types::Path::Class
	required=>1,
	coerce =>1,
);

has 'output_dir'=>(
	is =>'ro',
	isa =>Dir, #MooseX::Types::Path::Class
	required=>1,
	coerce =>1,
);

has [qw/group member/]=>(
	is=>'ro',
	isa=>'Bool',
);

has '_twig'=>(
	is =>'ro',
	isa =>'XML::Twig',
	lazy_build =>1,
);

# methods
sub _build__twig {
	XML::Twig->new(
		twig_handlers=>{
			entry=>\&_parse_entry,
		}
	);
}

# $uniref->parse(group=>1,member=>1);
sub parse {
	#my $self=shift;
	my ($self,%params)=validated_hash(
		\@_,
		group=> { isa => 'Bool', default => 0 },
		member=> { isa => 'Bool', default => 0 },
	);

	my $target_xml=$self->input;
	print "Parsing $target_xml\n";

	my $output_dir=$self->output_dir;

	open (GROUP, ">$output_dir/uniRef.txt") or die "cannot make UniRef.txt:$!\n" if $params{group}; 
	open (MEM, ">$output_dir/uniRefMember.txt") or die "cannot make UniRef.txt:$!\n" if $params{member}; 

	my $twig=$self->_twig;

	open (XML, "zcat $target_xml |") or die "Can't open $target_xml:$!\n";
	$twig->safe_parse(\*XML);
	$twig->purge;
	close XML;

	close GROUP if $params{group};
	close MEM if $params{group};
}

my $cnt_cluster=0;
sub _parse_entry{
	my ($twig,$entry)=@_;

	$cnt_cluster++;
	###############
	my ($entry_id,$entry_name,$mem_count,$common_taxon,$common_taxon_id)=('\\N','\\N',0,'\\N','\\N');
	my ($db_ref_type,$mem_id,$mem_acc,$is_rep,$is_sp)=('\\N','\\N','\\N',0,0);
	###############

	# 1.id 
	#<entry id="UniRef90_UPI00021A620C" updated="2011-10-19">
	$entry_id=$entry->att('id');

	# 2. name
	#<name>Cluster: UPI00023A620C related cluster</name>
	# <property type="member count" value="94"/>
	# <property type="common taxon" value="Eutheria"/>
	# <property type="common taxon ID" value="9347"/>
	$entry_name=$entry->first_child_text('name');

	foreach my $prop($entry->children('property')){
		$mem_count=$prop->att('value') if $prop->att('type') eq 'member count';
		$common_taxon=$prop->att('value') if $prop->att('type') eq 'common taxon';
		$common_taxon_id=$prop->att('value') if $prop->att('type') eq 'common taxon ID';
	}

	###############
	$entry_name=~s/Cluster: //g; #remove 'Cluster: '
	$common_taxon=$common_taxon eq 'unknown'? '\\N':$common_taxon; #replace uknown by '\\N'
	print GROUP "$cnt_cluster\t$entry_id\t$entry_name\t$mem_count\t$common_taxon\t$common_taxon_id\n";
	###############

	# 3. representative member
	#<representativeMember>
	#<dbReference type="UniProtKB ID" id="Q3ASY8_CHLCH">
	#<property type="UniProtKB accession" value="Q3ASY8"/>
	#<property type="UniParc ID" value="UPI00005D5563"/>
	#<property type="UniRef100 ID" value="UniRef100_Q3ASY8"/>
	#<property type="UniRef50 ID" value="UniRef50_P82335"/>
	#<property type="protein name" value="Parallel beta-helix repeat"/>
	#<property type="source organism" value="Chlorobium chlorochromatii (strain CaD3)"/>
	#<property type="NCBI taxonomy" value="340177"/>
	#<property type="length" value="36805"/>
	#<property type="isSeed" value="true"/>
	#</dbReference>
	#<sequence length="35213" checksum="C761D2E29FF1AC14">
	my $rep=$entry->first_child('representativeMember');
	my $db_ref=$rep->first_child('dbReference');
	$db_ref_type=$db_ref->att('type');
	$mem_id=$db_ref->att('id');

	foreach my $prop($db_ref->children('property')){
		$mem_acc=$prop->att('value') and last if $prop->att('type') eq 'UniProtKB accession';
	}

	###############
	$is_rep=1;
	$is_sp=$db_ref_type eq 'UniProtKB ID'? 1:0;
	print MEM "0\t$cnt_cluster\t$mem_id\t$mem_acc\t$is_rep\t$is_sp\n";
	###############

	# 4. member
	#<member>
	#<dbReference type="UniProtKB ID" id="F6VG02_HORSE">
	#<property type="UniProtKB accession" value="F6VG02"/>
	#<property type="UniParc ID" value="UPI0001FB30F0"/>
	#<property type="UniRef100 ID" value="UniRef100_F6VG02"/>
	#<property type="protein name" value="Uncharacterized protein"/>
	#<property type="source organism" value="Equus caballus (Horse)"/>
	#<property type="NCBI taxonomy" value="9796"/>
	#<property type="length" value="35233"/>
	#<property type="isSeed" value="true"/>
	#</dbReference>
	#</member>
	#<member>....</member>
	foreach my $mem($entry->children('member')){
		$db_ref=$mem->first_child('dbReference');
		$db_ref_type=$db_ref->att('type');
		$mem_id=$db_ref->att('id');

		$mem_acc='\\N';
		foreach my $prop($db_ref->children('property')){
			$mem_acc=$prop->att('value') and last if $prop->att('type') eq 'UniProtKB accession';
		}

		###############
		$is_rep=0;
		$is_sp=$db_ref_type eq 'UniProtKB ID'? 1:0;
		print MEM "0\t$cnt_cluster\t$mem_id\t$mem_acc\t$is_rep\t$is_sp\n";
		###############
	}


	$twig->purge;
}
__PACKAGE__->meta->make_immutable;
1;


