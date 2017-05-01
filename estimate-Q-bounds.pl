#!/usr/bin/perl -w
use strict;
open A,"< msieve.dat";
my @last_rrs;
my %bigct;
while (<A>)
{
    chomp;
    my ($xy,$rr,$aa) = split ":",$_;
    if (defined $aa)
    {
	my @rrs = split ",",$rr;
	my %last_rrx = ();
	for my $u (@last_rrs) { $last_rrx{$u} = 1 }
	my @dups;
	for my $u (@rrs) { if (defined $last_rrx{$u}) { push @dups, hex($u)} }
	sort {$a <=> $b} @dups;
	if ($#dups != -1) { $bigct{$dups[-1]}++ }
	@last_rrs = @rrs;
    }
}
for my $j (keys %bigct)
{
    print $j," ",$bigct{$j},"\n";
}
