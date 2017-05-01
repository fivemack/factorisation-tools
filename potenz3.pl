use strict;
my @files = glob("*.ath");
my %succ;

my @oddprimes=(3,5,7);

for my $w (@files)
{
    my @lines = ();
    open A,"< $w";
    my $last_key = -1;
    while (<A>)
    {
	chomp;
	my ($a,$b) = split "=",$_;
	my @ix;
	if ($b =~ /^2\^([0-9]+)/) { $ix[0] = $1 }
	if ($b =~ /^2\*/) { $ix[0] = 1 }
	for my $j (0..$#oddprimes)
	{
	    $ix[1+$j] = 0;
	    my $p = $oddprimes[$j];
	    if ($b =~ /\*$p\*/) { $ix[1+$j] = 1;}
	    if ($b =~ /\*$p\^([0-9]+)/) { $ix[1+$j] =$1; }
	}

	my $key = join ".",@ix;

	if ($last_key != -1)
	{
	    $succ{$last_key}{$key}++;
	}
	$last_key = $key;
    }
}

for my $u (sort {$a <=> $b} keys %succ)
{
    my $tot = 0; my @l = ();
    for my $v (keys %{$succ{$u}})
    {
	$tot+=$succ{$u}{$v};
	push @l,[$v,$succ{$u}{$v}];
    }
    if ($tot > 50)
    {
	print $u,"\t";
	for my $v (sort { $b->[1] <=> $a->[1] } @l)
	{
	    my $desc;
	    if (substr($v->[0],0,1) != substr($u,0,1)) { $desc = "*" }
	    print $desc.sprintf("%5.3f",$v->[1]/$tot)," ",$v->[0].$desc,"\t";
	}
	print "\n";
    }
}


