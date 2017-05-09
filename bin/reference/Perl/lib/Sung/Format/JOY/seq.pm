#===============================================================================
#         FILE:  seq.pm
#  DESCRIPTION:  --- 
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Sung Gong (ssg), sung@bio.cc
#      COMPANY:  BiO
#      VERSION:  1.0
#      CREATED:  06/09/2010 06:57:30 PM
#===============================================================================
package Sung::Format::JOY::seq;

use Moose; 
use Moose::Util::TypeConstraints;
use MooseX::StrictConstructor;
use namespace::clean -except=>'meta';
use Sung::Data::MyTypes qw(AA1 Env PirHeader);

has header=>(
	is => 'ro',
	isa => PirHeader,
);
=tmp
has env=>(
	is=>'ro',
	isa=>ENV,
	default=>'sequence',
);
=cut
#move header env to a sckeleton and subclassig it!
has seq=>(
	is=>'ro',
	isa=>AA1,
);




__PACKAGE__->meta->make_immutable;
1;


