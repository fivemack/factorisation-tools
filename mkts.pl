#!/usr/bin/perl
use strict;

my $skewmax = 250e6;
my @dats;
if (-e "ps/msieve.dat.p") { @dats = "ps/msieve.dat.p" }
push @dats, glob("ps/*/msieve.dat.p");
if (scalar @dats == 0) { die " Please ensure that ps/*/msieve.dat.p exist\n"; }

open T,"< ps/worktodo.ini";
my $N = <T>;
chomp $N;
close T;

my %gotit;

my ($lpx, $alim,$ntc) = @ARGV;
my $lp = $lpx;
my $ss = 14;
my $nlpa = 2; my $nlpr = 2;
my $batched = 0;
if ($lpx =~ m/([0-9]*):([0-9]*)/) { $ss=$2; $lp=$1; }
if ($lpx =~ m/([0-9]*)\.3[aA]:([0-9]*)/) { $ss=$2; $lp=$1; $nlpa = 3;}
if ($lpx =~ m/([0-9]*)\.3[rR]:([0-9]*)/) { $ss=$2; $lp=$1; $nlpr = 3;}
if (!defined $lp or !defined $alim) { die "Syntax: mkts.pl <large prime bound> <alim>\n" }
if (!defined $ntc) { print " Testing top eight (specify at end of command line; negative for batched run)\n"; $ntc=8 }
my $rlim = $alim;

if ($ntc < 0) { $ntc = -$ntc; $batched = 1; }

$ntc -= 1;

my $hst;
for my $u (0..$ntc) { $hst->[$u] = [-100,[]] }

sub handle($$$)
{
    my ($hst,$ntc,$lp)=@_;
    my @l = @{$lp}; if (scalar @l == 0) { return }
    my @t = split " ",$lp->[0]; 
    if ($t[6] > $hst->[0]->[0] && ! defined $gotit{$lp->[0]})
    {
	$gotit{$lp->[0]}=1;
	$hst->[0]->[0] = $t[6];
	$hst->[0]->[1] = [@l];
	@{$hst} = sort {$a->[0] <=> $b->[0]} @{$hst};
    }
}

my $skew;

for my $f (@dats)
{
    open A,"< $f";
    my @lines;
    while (<A>)
    {
	chomp;
	if ($_ =~ /^skew: ([0-9.]*)/)
	{
	    $skew = $1;
	}
	if ($_ =~ /^# norm/)
	{
	    if ($skew < $skewmax)
	    {
		handle($hst,$ntc,\@lines);
	    }
	    @lines=();
	}
	push @lines, $_;
    }
    close A;
    if ($skew < $skewmax) { handle($hst,$ntc,\@lines) }
}

# ok, this has pulled out the top N

my $alam = $nlpa * $lp / (log($alim)/log(2));
my $rlam = $nlpr * $lp / (log($rlim)/log(2));

my $mfbr = $nlpr*$lp; if ($mfbr>96) { $mfbr=96; }
my $mfba = $nlpa*$lp; if ($mfba>96) { $mfba=96; }

$alam = sprintf("%.1f",$alam);
$rlam = sprintf("%.1f",$rlam);

system "mkdir ts";

for my $u (0..$ntc)
{
    print $hst->[$u]->[0],"\t",$hst->[$u]->[1]->[0],"\n";
    open Q,"> ts/gnfs.".($ntc-$u);
    print Q "n: $N\n";
    print Q join "\n",@{$hst->[$u]->[1]};
    print Q "\nlpbr: $lp\nlpba: $lp\nmfbr: $mfbr\nmfba: $mfba\nalambda: ".$alam."\nrlambda: ".$rlam."\nalim: $alim\nrlim: $rlim\n";
    close Q;
}

my @sample_points;
for my $u (0..4)
{
    $sample_points[$u] = int($alim*($u+2.0)/6);
}

print "cd ts\n";
if ($ntc < 12 && $batched==0)
{
    print "for a in \$(seq 0 $ntc); do for b in ".(join " ",@sample_points),"; do /home/nfsworld/gnfs-batalov-old/gnfs-lasieve4I${ss}e -a gnfs.\$a -f \$b -c 3000 2> \$a.\$b.t & done; done;\n";
}
else
{
    print "for b in ".(join " ",@sample_points),"; do Q=\"\"; for a in \$(seq 0 $ntc); do /home/nfsworld/gnfs-batalov-old/gnfs-lasieve4I${ss}e -a gnfs.\$a -f \$b -c 3000 2> \$a.\$b.t & Q=\"\$Q \$!\"; done; echo \$Q; wait \$Q; done\n";
}
