#!/usr/bin/perl
#===============================================================================
#         FILE:  JOY.pm
#  DESCRIPTION:  --- 
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Sung Gong (ssg), sung@bio.cc
#      COMPANY:  BiO
#      VERSION:  1.0
#      CREATED:  06/09/2010 12:13:16 PM
#===============================================================================
package Sung::Data::Format::JOY

use Moose; 
use MooseX::StrictConstructor;
use namespace::clean -except=>'meta';

has header=>(
	is=>'ro',
	isa=>'PirHeader',
);

has env=>(
	is=>'ro',
	isa => 'Str',
);
#seq
has seq=>(
	is => 'rw',
	isa => 'Str',
);


__PACKAGE__->meta->make_immutable;
1;


