#
#===============================================================================
#
#         FILE:  JOY.pm
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Sungsam Gong (sung), sung@bio.cc
#      COMPANY:  Royal Brompton and Harefield NHS Trust
#      VERSION:  1.0
#      CREATED:  27/10/11 14:24:53
#     REVISION:  ---
#===============================================================================
package Sung::Data::MyTypes::JOY;

use namespace::autoclean;

# predeclare our own types
use MooseX::Types -declare=>[qw(Env AA1 seq sequence ss_phi TF solv_acc hbond_co hbond_co hbond_nh hbond_sc cispep hbond_het covbond_het disulph mcmc_amide mcmc_carb dssp pos_phi pc_acc ooi ESST PirHeader)];

my @env;
$env[0]='sequence';
$env[1]="secondary structure and phi angle";
$env[2]="solvent accessibility";
$env[3]="hydrogen bond to mainchain CO";
$env[4]="hydrogen bond to mainchain NH";
$env[5]="hydrogen bond to other sidechain/heterogen";
$env[6]="cis-peptide bond";
$env[7]="hydrogen bond to heterogen";
$env[8]="covalent bond to heterogen";
$env[9]="disulphide";
$env[10]="mainchain to mainchain hydrogen bonds (amide)";
$env[11]="Mainchain to mainchain hydrogen bonds (carbonyl)";
$env[12]="DSSP";
$env[13]="positive phi angle";
$env[14]="percentage accessibility";
$env[15]="Ooi number";

enum Env, \@env; 

type AA1, where {$_=~/^[ACDEFGHIJKLMNPQRSTVWY*]$/i},message{"$_ is not a regular one-letter amino acid code"};

type ss_phi, where {$_=~/^[CHEP*]$/i};
type TF,where {$_=~/^[TF*]$/};
type solv_acc,where {$_=~/^[TF*]$/};
type hbond_co,where {$_=~/^[TF*]$/};
type hbond_nh,where {$_=~/^[TF*]$/};
type hbond_sc,where {$_=~/^[TF*]$/};
type cispep,where {$_=~/^[TF*]$/};
type hbond_het,where {$_=~/^[TF*]$/};
type covbond_het,where {$_=~/^[TF*]$/};
type disulph,where {$_=~/^[TF*]$/};
type mcmc_amide,where {$_=~/^[TF*]$/};
type mcmc_carb,where {$_=~/^[TF*]$/};
type pos_phi,where {$_=~/^[TF*]$/};

type dssp,where {$_=~/^[CGEHI*]$/};
type pc_acc,where{$_=~/^\S{1}$/};
type ooi,where{$_=~/^\S{1}$/};

#>P1;1a25A
type PirHeader, where {$_=~/>[P1|F1|DL|DC|RL|RC|XX];\S+/},message{"$_ does not conform pir format header"};

no Moose::Util::TypeConstraints;
1;
