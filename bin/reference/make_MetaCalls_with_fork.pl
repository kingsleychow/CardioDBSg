#!/usr/bin/perl -w 
#===============================================================================
#
#         FILE:  make_MetaCalls_with_fork.pl
#
#        USAGE:  ./make_MetaCalls_with_fork.pl  
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  Alternatively, you can use a stored prodecure
#                'insert_metacalls_by_runname'
#       AUTHOR:  Dr. Sungsam Gong (sung), sung@bio.cc
#      COMPANY:  Royal Brompton and Harefield NHS Trust
#      VERSION:  1.0
#      CREATED:  12/06/2011 10:15:28 PM
#     REVISION:  ---
#===============================================================================
use lib '/data/Develop/Perl/lib';
use Sung::Manager::Config;
use Sung::Util::Dir;
use IO::File;
use Getopt::Long;
use Parallel::ForkManager;
use Time::HiRes qw(sleep);

my $dump_root='/data/Develop/CardioDB/Dump/_MetaCalls';

my $max_proc;
my $all;
my $sample_id;
my $dump='';
my $help;
GetOptions(
	'max_proc=i' => \$max_proc,
	'all!' => \$all,
	'sample_id:i' => \$my_sample_id,
	'run_name:s' => \$my_run_name,
	'dump!' => \$dump,
	'help!' => \$help,
) or &usage ();

&usage() and exit(0) if $help;

# Get DB config
my $db_config='/data/Develop/Perl/lib/Sung/Manager/Config/db.conf';
my $config=Sung::Manager::Config->get_config_from_file($db_config);
my $host=$config->{db}{host};
my $db=$config->{db}{cardiodb};
my $user=$config->{db}{user};
my $passwd=$config->{db}{passwd};
my $CARDIODB_ROOT=$config->{CARDIODB_ROOT};

MAIN: {
	mkdir $dump_root unless -d $dump_root;

	#process all samples 
	if($all){
		my $total; # NO. of child processor

		my $counter=0; # a counter
		my %sample_id; # key: counter, value: sample_id

		my $sql=`mysql -h $host -u $user -p$passwd $db --skip-column-name -e "select id from Samples"`;
		#my $sql=`mysql -h $host -u $user -p$passwd $db --skip-column-name -e "SELECT s.id FROM Samples s LEFT JOIN _MetaCalls m ON m.sample_id=s.id WHERE m.sample_id IS NULL GROUP BY s.id"`;
		my @ids=split(/\n/,$sql);
		foreach (@ids){
			$counter++;
			$sample_id{$counter}=$_;
		}
		$total=`mysql -h $host -u $user -p$passwd $db --skip-column-name -e "select count(id) from Samples"`;
		#$total=`mysql -h $host -u $user -p$passwd $db --skip-column-name -e "SELECT COUNT(DISTINCT s.id) FROM Samples s LEFT JOIN _MetaCalls m ON m.sample_id=s.id WHERE m.sample_id IS NULL"`;
		print "Total NO. of Samples: $total\n";
		my $bin=int($total / $max_proc + 1 );
		my $pm = new Parallel::ForkManager($max_proc);
		foreach my $proc (1 .. $max_proc){
			$pm->start and next; # do the fork

			my $sample_start=1 + ($bin)*($proc-1);
			my $sample_end=$sample_start + $bin -1 ;
			print "[PROC:$proc] $sample_start .. $sample_end\n"; 
			for my $dummy_cnt ($sample_start .. $sample_end){
				last if $dummy_cnt>$total;
				my $sample_id=$sample_id{$dummy_cnt};
				unless(-e "$dump_root/_MetaCalls.$sample_id.txt"){
					print ("mysql -h $host -u $user -p$passwd $db --skip-column-name -e \"CALL get_metacalls_by_sample_id($sample_id)\" | sed 's/NULL/\\\\N/g' > $dump_root/_MetaCalls.$sample_id.txt \n");
					system("mysql -h $host -u $user -p$passwd $db --skip-column-name -e \"CALL get_metacalls_by_sample_id($sample_id)\" | sed 's/NULL/\\\\N/g' > $dump_root/_MetaCalls.$sample_id.txt \n");
				}
			}

			$pm->finish; # do the exit in the child process
		}
		$pm->wait_all_children;
		if($dump){
			system("mysql -h $host -u $user -p$passwd $db < $CARDIODB_ROOT/Schema.backup/_MetaCalls.sql");
			&dump_files;
		}
	}else{
		if($my_run_name){
			unless($my_sample_id){
				if($dump){
					print ("mysql -h $host -u $user -p$passwd $db -e \"CALL insert_metacalls_by_runname('$my_run_name')\" \n");
					system("mysql -h $host -u $user -p$passwd $db -e \"CALL insert_metacalls_by_runname('$my_run_name')\" \n");
				}else{
					print ("mysql -h $host -u $user -p$passwd $db --skip-column-name -e \"CALL get_metacalls_by_runname('$my_run_name')\" | sed 's/NULL/\\\\N/g' \n");
					system("mysql -h $host -u $user -p$passwd $db --skip-column-name -e \"CALL get_metacalls_by_runname('$my_run_name')\" | sed 's/NULL/\\\\N/g' \n");
				}
			}else{
				die "\e[32m[USAGE]choose either '--run_name' or '--sample_id'\e[0m\n";
			}
		}
		if($my_sample_id){
			unless($my_run_name){
				if($dump){
					print ("mysql -h $host -u $user -p$passwd $db -e \"CALL insert_metacalls_by_sample_id($my_sample_id)\" \n");
					system("mysql -h $host -u $user -p$passwd $db -e \"CALL insert_metacalls_by_sample_id($my_sample_id)\" \n");
				}else{
					print ("mysql -h $host -u $user -p$passwd $db --skip-column-name -e \"CALL get_metacalls_by_sample_id($my_sample_id)\" | sed 's/NULL/\\\\N/g' \n");
					system("mysql -h $host -u $user -p$passwd $db --skip-column-name -e \"CALL get_metacalls_by_sample_id($my_sample_id)\" | sed 's/NULL/\\\\N/g' \n");
				}
			}else{
				die "\e[32m[USAGE]choose either '--run_name' or '--sample_id'\e[0m\n";
			}
		}
	}

}#end of MAIN

sub usage{
	die "\e[33m[USAGE] perl $0 
		--max_proc [int:No of Processors]: NO. of processor to fork in parallel 
		[Example]
			perl $0 --max_proc 10 --all --dump
			perl $0 --run_name MY_RUN_NAME (STDOUT) 
			perl $0 --run_name MY_RUN_NAME --dump (insert the result into _MetaCalls) 
			perl $0 --sample_id 10 (STDOUT)
			perl $0 --sample_id 10 --dump (insert the result into _MetaCalls)
	\e[0m\n";
}

sub dump_files{
	#system("mysql -h $host -u $user -p$passwd $db --skip-column-name -e \"CALL insert_metacalls_by_sample_id($my_sample_id)\" \n");
	my $ref_files=Sung::Util::Dir->new(dir=>$dump_root)->get_files('txt');;
	foreach my $file (@{$ref_files}){
		print "\e[32m$file\e[0m\n";
		#system("mysqlimport -h $host -u $user -p$passwd $db _MetaCalls --lock-tables $dump_root/$file");
		system("mysql -h $host -u $user -p$passwd $db -e \"load data local infile '$dump_root/$file' into table _MetaCalls; show warnings\"");
	}   
}

