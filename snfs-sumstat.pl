use strict;
my (@alg, @rat);
my $deg;

open A,"< snfs";
while (<A>)
{
    if (/c([0-9]): ([-0-9]+)/) { $alg[$1]=$2; if ($1>$deg) { $deg=$1; } }
    if (/Y([0-9]): ([-0-9]+)/) { $rat[$1]=$2; }
}
close A;

my @vals;

open A,"< snfs.lasieve-1.268000000-268000999";
while (<A>)
{
    my ($c,$r,$a)=split ":",$_;
    my ($X,$Y)=split ",",$c;
    my $rr = $rat[1]*$X+$rat[0]*$Y;
    my $aa = 0;
    for my $u (0..$deg) { $aa += $alg[$u]*$X**$u*$Y**($deg-$u); }
    $rr = log(abs($rr))/log(2); $aa = log(abs($aa))/log(2);
    push @vals,[$rr,$aa];
}

my @median;

# actually compute the summary statistics
for my $j (0,1)
{
    my @meds = ();
    for my $u (@vals) { push @meds, $u->[$j]; }
    @meds = sort { $a <=> $b } @meds;
    for my $q (0.1,0.25,0.5,0.75,0.9) { print $j," ",$q,"\t",$meds[int($#meds*$q)], "\n"; }

    # now we want the narrowest interval covering half the numbers
    my $ni = 1e99;
    my ($il,$ir);
    my $half = $#meds/2;
    $median[$j] = $meds[$half];
    
    for my $q (0..$half)
    {
	my $nx = $meds[$q+$half]-$meds[$q];
	if ($nx<$ni)
	{
	    $ni=$nx; $il=$meds[$q]; $ir=$meds[$q+$half];
	}
    }
    print "$j  $il .. $ir\n\n";
}

# try to find the smallest disc
my $scale = 0.15;
my $bmrsf = 1e99;
my @c = @median;  my @cn;
while ($scale > 0.001)
{
    for my $dxx (-5..5)
    {
	for my $dyy (-5..5)
	{
	    my ($tx,$ty) = @c;
	    $tx+=$dxx*$scale; $ty+=$dyy*$scale;
	    my @rads = ();
	    for my $u (@vals)
	    {
		my $r = sqrt( ($u->[0]-$tx)**2 + ($u->[1]-$ty)**2 );
		push @rads, $r;
	    }
	    @rads = sort { $a <=> $b } @rads;
	    my $medrad = $rads[$#rads/2];
	    if ($medrad < $bmrsf) { $bmrsf = $medrad; 	print "Centre $tx,$ty median $medrad @ $scale\n";  @cn = ($tx,$ty);}
	}
    }
    @c = @cn;
    $scale = $scale * 0.8;
}
