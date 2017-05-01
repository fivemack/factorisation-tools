sub get_c1($)
{
    my ($fn) = @_;
    my $c1_key="file not found";
    my $ox = open K,"< $fn";
    if ($ox != 0)
    {
	while (<K>) 
	{
	    if (/^c1: ([0-9-]*)/) { $c1_key = $1; }
	}
    }
    close K;
    return $c1_key;
 }

my @files = split "\n",`find . -name gnfs.4`;

for my $u (@files)
{
    # get the directory name, cd there, run scoretes
    my @terms = split "/",$u; my $dname = join "/",@terms[0..$#terms-1];
    my @scorets = split "\n",`cd $dname && perl /home/nfsworld/aliquot/scorets.pl`;
    # identify which of the gnfs.* is the one used for sieving
    my $rname = join "/",@terms[0..$#terms-2];
    my $c1_used = get_c1("$rname/s/gnfs");
    my $line = -1;
    for my $j (0..4)
    {
	my $cx = get_c1("$dname/gnfs.$j");
	if ($cx == $c1_used) { $line = $j }
    }
    next if ($line == -1);
    next unless ($#scorets == 4);

    my ($dummy,$y, $sigy, $t, $sigt) = split "\t",$scorets[$line];
    $y/=1e4; $sigy/=1e4;

    # now we need to measure actual-yield and actual-time
    # and also number-of-Q which is possibly more fiddly
    
    my $tottime = 0;
    open T,"< $rname/s/ggnfs.log" or next;
    
    while (<T>) { $tottime += (split(" ",$_))[1]; }
    close T;
    open L,"< $rname/la/msieve.log" or next;
    
    my $rcount = -1;
    while (<L>)
    {
	if (/found [0-9]* hash collisions in ([0-9]*) relations/) { $rcount = $1 }
    }
    close L;
    next if ($rcount == -1);

    my @lines = glob("$rname/s/gnfs.*");
    my $q0=1e9, $q1=0;
    for $x (@lines)
    {
	if ($x =~ m/gnfs.lasieve-..([0-9]+)-([0-9]+)/)
	{
	    if ($1 < $q0) { $q0=$1}
	    if ($2 > $q1) { $q1=$2}
	}
    }
    my $tq = $q1-$q0;
    my $tt = $tottime/$rcount;
    my $yy = $rcount/$tq;

    my $zy = ($yy-$y)/$sigy;
    my $zt = ($tt-$t)/$sigt;
    print "$rname\t";
    print sprintf("%10d%10d%10d",$tottime,$rcount,$tq);
    print "\t";
    print sprintf("%5.2f\t%6.4f\t",$yy,$tt);
    print sprintf("%5.2f\t%6.2f\t",$y,$sigy);
    print sprintf("%6.4f\t%6.4f\t",$t,$sigt);
    print sprintf("%6.1f%6.1f\n",$zy,$zt);
}
