#!/usr/bin/perl -w
#===============================================================================
#
#         FILE:  Config.pm
#
#  DESCRIPTION:  process configurations
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Sung Gong (), sung@bio.cc
#      COMPANY:  BiO
#      VERSION:  1.0
#      CREATED:   01/11/11 14:46:24
#     REVISION:  ---
#===============================================================================
package Sung::Manager::Config;

use Moose; 
use namespace::autoclean;

# a Moose Role implementing Config::Any
with 'MooseX::SimpleConfig';

my $db_config='/data2/users_data2/kingsley/CardioDBS/Perl/lib/Sung/Manager/Config/db.conf'; #ck
my $mirror_config='/data2/users_data2/kingsley/CardioDBS/Perl/lib/Sung/Manager/Config/mirror.conf'; #ck
warn "default $db_config not found\n" unless -s $db_config;
warn "default $mirror_config not found\n" unless -s $mirror_config;

has '+configfile' =>(
#	default =>sub{[qw/$db_config $mirror_config/]},
	default =>$db_config,
);

__PACKAGE__->meta->make_immutable;
1;


