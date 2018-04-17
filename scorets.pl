#!/usr/bin/perl
use strict;

sub meansd($)
{
    my ($dr)=@_;
    my ($n,$s,$ss)=(0,0);
    for my $u (@{$dr}) { if (defined $u) {$n++; $s+=$u; $ss+=$u*$u } }
    my $mu = $s/$n;
    my $ess = $ss/$n;
    return ($mu,sqrt(($ess-$mu*$mu)));
}

my @files = glob("*.*.t");

my ($yield,$time);
for my $u (@files)
{
    $u =~ m/^(.+)\.([0-9]+)\.t/;
    my ($id,$slice)=($1,$2);
    open A,"< $u";
    my @xlines = <A>;
    close A;
    my @lines;
    for my $v (@xlines) { push @lines, split "\r",$v }
    if ($#lines != -1)
    {
	# restrict to lines containing 'total yield'
	@lines = grep(/^total yield/, @lines);
	
	$lines[1] =~ m/q=([0-9]+) \(/; my $q0 = $1;
	if ($u =~ m/[0-9]*\.([0-9]*)\.t/) { $q0 = $1; } # if the q0 is in the filename
	$lines[-1] =~ m/total yield: ([0-9]*).*q=([0-9]*).*\(([0-9.]+) sec\/rel\)/;
	push @{$yield->{$id}},($1*10000/($2-$q0));
	push @{$time->{$id}},$3;
    }
}

for my $q (sort {$a <=> $b} (keys %{$yield}))
{
    print $q,"\t";
    my @line;
    for my $stat ($yield->{$q}, $time->{$q})
    {
	my ($mu,$sigma) = meansd($stat);
	push @line,($mu,$sigma); 
    }
    print sprintf("%.1f",$line[0]),"\t",sprintf("%.1f",$line[1]),"\t";
    print sprintf("%.4f",$line[2]),"\t",sprintf("%.6f",$line[3]),"\n";
}
