my @ein = glob "gnfs.lasieve-0.*";
for my $u (@ein)
{
    open A,"< $u";
    while (<A>)
    {
	$h2=$h1; $h1=$h0; $h0=$_;
	if ($h1 =~ /\000/)
	{
	    my $a = hex((split ",",$h0)[-1]);
	    my $b = hex((split ",",$h2)[-1]);
	    print "nohup ../../gnfs-batalov/gnfs-lasieve4I15e -M 1 -a -f $b -c ",$a-$b,"&\n";
	}
    }
}
