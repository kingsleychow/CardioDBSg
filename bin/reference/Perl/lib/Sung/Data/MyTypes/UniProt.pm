#
#===============================================================================
#
#         FILE:  UniProt.pm
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Sungsam Gong (sung), sung@bio.cc
#      COMPANY:  Royal Brompton and Harefield NHS Trust
#      VERSION:  1.0
#      CREATED:  27/10/11 14:26:52
#     REVISION:  ---
#===============================================================================
package Sung::Data::MyTypes::UniProt;
use Moose;
use namespace::autoclean;
use MooseX::StrictConstructor;

use MooseX::Types -declare=>[qw//];
# methods

__PACKAGE__->meta->make_immutable;
1;


