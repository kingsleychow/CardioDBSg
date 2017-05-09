#===============================================================================
#         FILE:  Parser.pm
#  DESCRIPTION:  --- 
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Sung Gong (ssg), sung@bio.cc
#      COMPANY:  BiO
#      VERSION:  1.0
#      CREATED:  06/10/2010 12:13:52 PM
#===============================================================================
package Sung::Parser;

use Moose; 
#use Moose::Util::TypeConstraints;
use MooseX::StrictConstructor;
use namespace::clean -except=>'meta';
use Sung::Data::MyTypes qw(FileHandle); # see Sung::Data::MyTypes::File 
										# same with MooseX::Types::Moose (FileHandle);

has input=>(
	is =>'ro',
	isa => FileHandle,
	coerce=>1,
);

__PACKAGE__->meta->make_immutable;
1;


