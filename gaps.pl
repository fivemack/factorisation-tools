# find gaps in lasieve runs

use strict;
my @w;
if ($#ARGV != -1) { @w=@ARGV } else { @w = glob("*lasieve*") }

my ($smallQ,$bigQ)=(1e12,-1e12);

my (@bucket,@notyet);

for my $u (@w)
{
    print STDERR $u,"\r";
    $u =~ m/.lasieve\-(.)\.(.*)\-(.*)$/;
    my ($side,$q0,$q1)=($1,$2,$3);
    if ($q0<$smallQ) {$smallQ=$q0}
    if ($q1>$bigQ) {$bigQ=$q1}
    my $qlib;
    open A,"< $u";
    while (<A>)
    {
	my ($xy,$rr,$aa)=split ":",$_;
	my $rel;
	if ($side==0) { $rel=$aa; } else { $rel = $rr; }
	my $Q = hex((split ",",$rel)[-1]);
	if ($Q > $q0 && $Q < $q1)
	{
	    if ($Q>$qlib) {$qlib=$Q}
	    $bucket[$Q/10000]++;
	}
    }
    for my $Q (1+$qlib/10000 .. $q1/10000) { $notyet[$Q]=1}
}

print "\n\n",$smallQ," ",$bigQ;
for my $Q ($smallQ/10000 ... $bigQ/10000)
{
    if ($notyet[$Q]!=1)
    {
	print $Q," ",$bucket[$Q],"\n";
    }
}
