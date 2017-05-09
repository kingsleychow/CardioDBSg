#
#===============================================================================
#
#         FILE:  Dir.pm
#
#  DESCRIPTION:  Get 'dir' and 'extention' and return list of files 
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Sungsam Gong (sung), sung@bio.cc
#      COMPANY:  Royal Brompton and Harefield NHS Trust
#      VERSION:  1.0
#      CREATED:  29/11/11 14:31:55
#     REVISION:  ---
#===============================================================================
package Sung::Util::Dir;
use Moose;
use namespace::autoclean;
use MooseX::StrictConstructor;

use lib '/data/Develop/Perl/lib';
use Sung::Data::MyTypes qw/Dir/;

has dir=>(
	is => 'ro',
	isa =>Dir, #MooseX::Types::Path::Class
	required => 1,
	coerce => 1,
);

# methods
# a pattern search
sub get_files{
	my $self=shift;
	my $ext=shift;

	my @files;
	opendir (DH, $self->dir) or die "cannot open",$self->dir,"$!\n";
	if($ext){
		# @files=grep {/\.$ext$/ and -f $self->dir.'/'.$_ } readdir DH
		# 24/Jan/2013
		@files=grep {/$ext/ and -f $self->dir.'/'.$_ } readdir DH
	}else{
		@files=grep {$self->dir.'/'.$_ } readdir DH
	}
	return \@files;
}

__PACKAGE__->meta->make_immutable;
1;


