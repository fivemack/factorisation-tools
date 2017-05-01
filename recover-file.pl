my %ph;
while (<>)
{
    chomp;
    my ($number, $factors) = split "=",$_;
    my @primes = split "\\*",$factors;
    for my $g (0..$#primes-1)
    {
	my $px = $primes[$g];
	if ($px =~ m/([0-9]*)\^[0-9]*/) { $px = $1 }
	$ph{$px}=1;
    }
}

print join "\n",((sort {$a <=> $b} keys %ph));
