use strict;
my @files = glob "ps/d*/msieve.dat.p";
my $curves;
my %dedup;
for my $f (@files)
{
    open A,"< $f";
    my %tc;
    while (<A>)
    {
	chomp;
	my @t = split " ",$_;
	$tc{$t[0]} = join " ",@t[1..$#t];
	if ($t[0] eq "Y1:")
	{
	    if (! defined $dedup{$tc{"c0:"}})
	    {
		my %ng = %tc;
		push @{$curves}, \%ng;
		$dedup{$tc{"c0:"}}=1;
	    }
	    %tc = ();
	}
    }
    close A;
}

open A,"< ps/worktodo.ini";
my $N = <A>;
close A;
chomp $N;

my $ncurves = scalar @{$curves};
my @scores;

print $ncurves," polynomials found\n";
for my $u (0 .. $ncurves)
{
    my @k = split " ",$curves->[$u]->{"#"};
    push @scores,[$k[5],$u];
}

@scores = sort { $b->[0] <=> $a->[0] } @scores;

my $LIM=39000000;

mkdir "tsx";

for my $j (0..9)
{
    open A,"> tsx/gnfs.$j";
    print A "n: $N\n";
    my %qq = %{$curves->[$scores[$j]->[1]]};
    for my $u (keys %qq)
    {
	print A $u," ",$qq{$u},"\n";
    }
    print A <<EOX;
lpbr: 30
lpba: 30
mfbr: 60
mfba: 60
alambda: 2.6
rlambda: 2.6
alim: $LIM
rlim: $LIM
EOX
   close A;
    print "/home/nfsworld/gnfs-batalov/gnfs-lasieve4I14e -a gnfs.$j -f ",$LIM/3," -c 100000 2> $j.t &\n";
}
