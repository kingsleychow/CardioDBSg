#===============================================================================
#         FILE:  JOY.pm
#  DESCRIPTION:  --- 
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Sung Gong (ssg), sung@bio.cc
#      COMPANY:  BiO
#      VERSION:  1.0
#      CREATED:  06/09/2010 03:09:34 PM
#===============================================================================
package Sung::Parser::JOY;

use Moose; 
use Moose::Util::TypeConstraints;
use MooseX::StrictConstructor;
use namespace::clean -except=>'meta';
extends 'Sung::Parser';

my %env_code;	# 1st key: pdb_local_rescued_res_num
					# 2nd key: env number
					# value: code
has result=>(
	is => 'rw',
	isa => 'HashRef',
	
);

sub parse {
	my ($self, $fh)=@_;

	$/=">";
	while(<$fh>){
		if (/P1;/){
			my ($header,$en,@seq)=split(/\n/,$_);
			$header=~s/P1\;//g;

			my ($local_res_num);
			foreach my $seq(@seq){
				$seq=~s/\*$//g;
				$seq=~s/\>$//g;
				my (@residues)=split(//,$seq);
				foreach my $residue(@residues){
					next if $residue eq '-';
					++$local_res_num;

					$env_code{$local_res_num}{$env{$en}}=$residue;
				}#endof foreach residue
			}#foreach sequence
		}#end of if
	}#endof while	
	# ENV
	# ss_phi  :	(HEPC): 	$env_code{$res_num}{2}
	# solv_acc: TF;Aa		$env_code{$res_num}{3}
	# hbond_sc: TF;Ss		$env_code{$res_num}{6}
	# hbond_co: TF;Oo		$env_code{$res_num}{4}
	# hbond_nh: TF;Nn		$env_code{$res_num}{5}
	$fh->close;	
}
__PACKAGE__->meta->make_immutable;
1;


