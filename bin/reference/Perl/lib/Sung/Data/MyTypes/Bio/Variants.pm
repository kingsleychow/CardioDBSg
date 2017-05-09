#
#===============================================================================
#
#         FILE:  Variants.pm
#
#  DESCRIPTION:  Variants types
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Sungsam Gong (sung), sung@bio.cc
#      COMPANY:  Royal Brompton and Harefield NHS Trust
#      VERSION:  1.0
#      CREATED:  11/29/2011 03:02:42 PM
#     REVISION:  ---
#===============================================================================
package Sung::Data::MyTypes::Bio::Variants;
use namespace::autoclean;

# predeclare our own types
use MooseX::Types -declare=>[qw/MutType/];

my @mut_types=qw/SNP Ins Del CompIns CompDel Comp/;
enum MutType, \@mut_types; 

1;


