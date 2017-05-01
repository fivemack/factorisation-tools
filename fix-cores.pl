my @msieve_pids = split " ",`pidof msieve`;
my @ox = (1,1,1,1,1,1,1,1);
for my $u (@msieve_pids)
{
    if ($u != 2802)
    {
	open A,"< /proc/$u/numa_maps";
	while (<A>)
	{
	    if (/heap/)
	    {
		$numal = $_;
	    }
	}
	close A;
	print "# $numal";
	my @nt = split " ",$numal;
	my $nm = -1, $nc = -1;
	for my $u (@nt)
	{
	    if ($u =~ /N(.)=([0-9]*)/)
	    {
		if ($2 > $nm) { $nm=$2; $nc=$1; }
	    }
	}
	my $K = 6*$nc + $ox[$nc]; $ox[$nc]++;
	push @tasksets,"taskset -pc $K $u";
    }
}
print join " ",@ox,"\n\n";
    
print join "\n",@tasksets;
