#! /usr/bin/perl -w
use strict;
use Cwd;
use File::Copy;
my $path = getcwd();

$path =~ m#/([0-9]+\.[0-9]+)[./]#;
my @paths = split "\n",`find /home/nfsworld -maxdepth 1 -name "aliquot*" -type d`;

my @searched; my $found = "";

# see if you're in a local /la directory
if ($path =~ m#/la$#)
{
    my $hd = "$path/../s";
    if (! -d $hd)
    {
	push @searched, $hd;
    }
    else
    {
	$found = $hd;
    }
}

# look in all the plausible places you might be running the sieving
if ($found eq "")
{
    for my $d (@paths)
    {
	my $hd = "$d/$1/s";
	
	if (! -d $hd )
	{
	    push @searched, $found;
	}
	else
	{
	    $found = $hd;
	    last;
	}
    }
}

if ($found eq "") { print "Can't find relations; searched ".join(" ",@searched)."\n"; die }

copy("$found/../ps/worktodo.ini",".");
[ -e "$found/gnfs" ] || die "$found/gnfs not found\n";

open A,"< $found/gnfs";
my %lh;
while (<A>)
{
    if (/(.*): (.*)/) { $lh{$1}=$2; }
}
close A;

my @k = (["N","n"],["SKEW","skew"],["A0","c0"],["A1","c1"],["A2","c2"],["A3","c3"],["A4","c4"],["A5","c5"],["A6","c6"],["R0","Y0"],["R1","Y1"]);
open A,"> msieve.fb";
for my $v (@k)
{
    if (defined $lh{$v->[1]})
    {
	print A $v->[0]," ", $lh{$v->[1]},"\n";
    }
}
close A;

print "cat $found/gnfs.lasieve* > msieve.dat &\n";
