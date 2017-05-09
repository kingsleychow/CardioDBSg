#!/usr/bin/perl -w 
#===============================================================================
#
#         FILE:  test_uniprot_parser.pl
#
#        USAGE:  ./test_uniprot_parser.pl  
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Sungsam Gong (sung), sung@bio.cc
#      COMPANY:  Royal Brompton and Harefield NHS Trust
#      VERSION:  1.0
#      CREATED:  30/10/11 12:03:00
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;

#use lib './Sung/Parser::UniProt::XML::UniRef';
use Sung::Parser::UniProt::XML::UniRef; # a Moose class

my $file='/data/Mirror/UniProt/uniref/uniref90/uniref90.xml.gz';
my $output_dir='/data/Store/UniProt';

#my $uniref=Sung::Parser::UniProt::XML::UniRef->new(input=>$file, output_dir=>$output_dir, group=>1,member=>1);
my $uniref=Sung::Parser::UniProt::XML::UniRef->new(input=>$file, output_dir=>$output_dir);

# group=>1: make UniRef.txt
# member=>1: make UniRefMem.txt
$uniref->parse(group=>1,member=>1);
#$uniref->parse();
