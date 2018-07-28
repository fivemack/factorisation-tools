#!/usr/bin/perl -w
use strict;
my $ect=0; my $line;
while (<>)
{
    if (/error -([0-9]+) reading relation ([0-9]+)/) { $ect++; }
    else { if ($ect==0) { print } else {print "  $ect errors\n"; $ect=0; } }
}
if ($ect != 0)
{
    print "  $ect errors\n";
}
