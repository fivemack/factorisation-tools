#! /usr/bin/perl -w
use strict;
use Cwd;
my $path = getcwd();

$path =~ m#/([0-9]+\.[0-9]+)[./]#;
my $num = $1;
my @searchpath;
if (-e "$path/../s") { push @searchpath,"$path/../s"; }

my @apaths = split "\n",`find /home/nfsworld -maxdepth 1 -name "aliquot*" -type d`;

for my $u (@apaths) { push @searchpath,"$u/$1/s"; }

my $hd = "";
for my $t (@searchpath)
{
    if (-d $t )
    {
	$hd = $t; last;
    }
}

if ($hd eq "")
{
    die "Cauldn't find sieve directory in ".(join " ",@searchpath)." so cannot proceed automatically\n"
}

my $mkname = "Makefile";
if (! -e "$hd/$mkname") { $mkname = "Makefile.g"; }
if (! -e "$hd/$mkname") { die "Can't figure out name of makefile in $hd\n" }

print <<"EOM";
A=\$(awk '{a+=\$2} END {print a}' < $hd/ggnfs.log)
echo \$A \$(echo "scale=4;\$A.00/86400.00" | bc)  >> msieve.log 
ls -l $hd/gnfs.lasieve-0.* >> msieve.log 
cat $hd/{gnfs,$mkname} >> msieve.log
EOM

# try to find the logs directory
if (-d "$hd/../../logs")
{
    print "mv msieve.log $hd/../../logs/$num.log\n";
}
