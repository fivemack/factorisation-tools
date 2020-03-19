open A,"< ../worktodo.ini";
my $N = <A>;
my @things;
my @labels = ("c5","c4","c3","c2","c1","c0","Y1","Y0");
my $cx = 119; my $ct = 0;
open B,"< ../msieve.dat.ms";
while (<B>)
{
    chomp;
    my $line = $_;
    my @terms = split " ",$line;
    my $score = $terms[-1];
    if ($ct<=$cx)
    {
	$things[$ct]=[$score, $line];
    }
    else
    {
	if ($score < $things[$cx]->[0])
	{
	    #	    print $line;
	    $things[$cx]=[$score, $line];
	    @things = sort {$a->[0] <=> $b->[0]} @things;
	}
    }
    $ct = 1+$ct;
    if ($ct == 1+$cx)
    {
	@things = sort {$a->[0] <=> $b->[0]} @things;
    }
}
close B;

print join " ",map($_->[0],@things);

$date = `date +%s`;    
open B,"> in.$date";
for my $u (0..$cx)
{
    print B "n: $N";
    my @terms = split " ",$things[$u]->[1];
    for my $v (0..$#labels)
    {
	print B "$labels[$v]: $terms[$v]\n";
    }
    print B "\n";
}
close B;
    
