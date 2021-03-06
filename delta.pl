#!/usr/bin/perl -w
use strict;

my %oldstep;

open A,"< report.$ARGV[0]";
while (<A>)
{
    my ($n, $step) = split "\t",$_;
    $oldstep{$n} = $step;
}
close A;

open B,"< report.$ARGV[1]";
while (<B>)
{
    my ($n, $step) = split "\t",$_;
    if (defined $oldstep{$n})
    {
	if ($oldstep{$n} eq "not started")
	{
	    print "cat $n.ath\n";
	}
	else
	{
	    my $nsteps = $step - $oldstep{$n} + 3;
	    if ($nsteps != 3)
	    {
		print "tail -n $nsteps $n.ath\n";
	    }
	}
    }
}

