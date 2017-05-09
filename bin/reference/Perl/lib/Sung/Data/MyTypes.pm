#
#===============================================================================
#
#         FILE:  MyTypes.pm
#
#  DESCRIPTION: This package is a combined library of Moose types  
#             : with the help of 'MooseX::Types::Combine'
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Sungsam Gong (sung), sung@bio.cc
#      COMPANY:  Royal Brompton and Harefield NHS Trust
#      VERSION:  1.0
#      CREATED:  30/10/11 15:18:50
#     REVISION:  ---
#===============================================================================
package Sung::Data::MyTypes;

# http://search.cpan.org/~drolsky/MooseX-Types-0.30/lib/MooseX/Types/Combine.pm
use base 'MooseX::Types::Combine';
eval require MooseX::Types::Path::Class;
use namespace::autoclean;

__PACKAGE__->provide_types_from(
	qw/MooseX::Types::Path::Class
	Sung::Data::MyTypes::Bio::Variants
	Sung::Data::MyTypes::File
	Sung::Data::MyTypes::JOY
	Sung::Data::MyTypes::UniProt/);
1;
