my @infiles = glob("x??");
my @outfiles = glob("*.s2");
for my $u (@infiles)
{
    open A,"< $u";
    while (<A>)
    {
	chomp;
	$curves{$_}=1;
	/SIGMA=([0-9]+)/; $curve{$1}=$_; $state{$1}=1;
    }
    close A;
}
for my $u (@outfiles)
{
    open B,"< $u";
    while (<B>)
    {
	if (/sigma=3:([0-9]+)/) { $thissig = $1; }
	if (/Step 2 took/) { $state{$thissig} = 2; }
    }
    close B;
}

open C,"> extra";
for my $a (%curve)
{
    if ($state{$a}==1) { print C $curve{$a},"\n"; }
}
