#! /usr/bin/perl -w
# list status of all numbers

use strict;

sub read_ecmcache($)
{
    my ($fn) = @_;
    my %t = ();
    open A,"< $fn";
    while (<A>)
    {
	chomp;
	my ($num,$curves) = split " ",$_;
	$t{$num}=$curves;
    }
    return \%t;
}

sub summ($)
{
    my ($n) = @_;
    my $ll = log($n)/log(10);
    return "C".(1+int($ll)).".".substr($n,0,3);
}

my @ms = split "\n",`ps \$(pidof msieve)`; my @mx;
for my $M (@ms) { my @mt = split '\s',$M; if ($mt[-2] eq "-v") { push @mx,$mt[-1] } }

my @rawterms = (glob "[0-9]*[0-9][0-9]");
my @terms;
for my $u (@rawterms)
{
    if ($u =~ m/^[0-9]+$/) { push @terms, $u }
}
my @realterms;

my %xx;

for my $u (@terms)
{
    if (-e "$u.gpl" && -e "$u.ecm.cache")
    {
	push @realterms,$u;
    }
    else
    {
	$xx{$u}="not started";
    }
}

my (%T1,%T2);
for my $u (@realterms) { $T1{$u} = read_ecmcache("$u.ecm.cache"); }
sleep(60);
for my $u (@realterms) { $T2{$u} = read_ecmcache("$u.ecm.cache"); }

for my $u (@realterms)
{
    my $lastline;
    open A,"< $u.gpl";
    while (<A>) { chomp;$lastline=$_ }
    close A;
    if (defined $lastline)
    {
	my ($qq,$rr) = split " ",$lastline;
	$xx{$u}=$qq+1;
    }
    else
    {
	$xx{$u}="unknown";
    }
}

my @gg = glob "gnfs.*";
for my $G (@gg) { $G = substr($G,5) }

system "date";

for my $v (sort {$a <=> $b} @terms)
{
    print $v,"\t",$xx{$v},"\t";
    my $info = 0;
    for my $M (@mx)
    {
	if (defined $T1{$v}->{$M})
	{
	    print "MPQS on ",summ($M),"\n";
	    $info=4;
	}
    }
    for my $G (@gg)
    {
	if (defined $T1{$v}->{$G})
	{
	    open A,"< gnfs.$G/msieve.log";
	    my $mss = "unknown";
	    while (<A>)
	    {
		if (/searching leading coefficients/) { $mss = "polsel" }
		if (/polynomial selection complete/) { $mss = "sieving" }
		if (/RelProcTime/) { $mss = "making matrix" }
		if (/commencing Lanczos/) { $mss = "lanczos" }
		if (/BLanczosTime/) { $mss = "sqrt phase" }
		if (/prp/) { $mss = "finished" }
	    }
	    close A;
	    print "scripted GNFS here on ",summ($G),": $mss\n";
	    $info = 1;
	}
    }

    for my $j (keys %{$T1{$v}})
    {
	if (defined $T2{$v}->{$j} && ($T2{$v}->{$j} != $T1{$v}->{$j}))
	{
	    print "ECM here on ", summ($j)," (",int($T2{$v}->{$j}),")\n";
	    $info = 2;
	}
    }
    
    my $dirname = "$v.$xx{$v}";
    if ($info == 0 && -d $dirname) 
    {
	print "GNFS being contemplated in $dirname\n";
	$info = 3;
    }
    if ($info == 0)
    {
	if ($xx{$v} ne "not started") { print " either stalled or GNFS elsewhere\n" }
	else { print "\n" }
    }
}
