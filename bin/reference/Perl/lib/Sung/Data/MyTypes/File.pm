#
#===============================================================================
#
#         FILE:  File.pm
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Sungsam Gong (sung), sung@bio.cc
#      COMPANY:  Royal Brompton and Harefield NHS Trust
#      VERSION:  1.0
#      CREATED:  30/10/11 16:09:34
#     REVISION:  ---
#===============================================================================
package Sung::Data::MyTypes::File;

use namespace::autoclean;

# predeclare our own types
use MooseX::Types -declare=>[qw/FileHandle/];

# import legacy Moose Types
use MooseX::Types::Moose FileHandle=>{-as=>'MooseFileHandle'}, qw/Str ScalarRef/;

#filehandle
subtype FileHandle, as MooseFileHandle;
coerce FileHandle, from Str, via {require IO::File; IO::File->new($_,'r') or die "cannot open $_:$!\n"};
coerce FileHandle, from ScalarRef, via {require IO::File; IO::File->new($_,'r')};

1;

