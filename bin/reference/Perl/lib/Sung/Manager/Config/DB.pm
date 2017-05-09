#
#===============================================================================
#
#         FILE:  DB.pm
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Sungsam Gong (sung), sung@bio.cc
#      COMPANY:  Royal Brompton and Harefield NHS Trust
#      VERSION:  1.0
#      CREATED:  29/11/11 17:17:57
#     REVISION:  ---
#===============================================================================
package Sung::Manager::Config::DB;
use Moose;
use namespace::autoclean;
use MooseX::StrictConstructor;
use lib '/data/Develop/Perl/lib';
use Sung::Manager::Config;

my $db_config='/data/Develop/Perl/lib/Sung/Manager/Config/db.conf';
warn "default $db_config not found\n" unless -s $db_config;
my $config=Sung::Manager::Config->get_config_from_file($db_config);

my $host=$config->{db}{host};
my $db=$config->{db}{cardiodb};
my $user=$config->{db}{user};
my $passwd=$config->{db}{passwd};

__PACKAGE__->meta->make_immutable;
1;


