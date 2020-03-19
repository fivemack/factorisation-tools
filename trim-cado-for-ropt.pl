#!/usr/bin/perl
open A,"< ../worktodo.ini";
my $N = <A>;
my @things;
my @labels = ("c5","c4","c3","c2","c1","c0","Y1","Y0");
my $cx = $ARGV[1]; my $ct = 0;

print STDERR "collecting $cx from $ARGV[0]\n";
$cx = $cx-1;
open B,"< $ARGV[0]";
my $collect = 0;
    
while (<B>)
{
    chomp;
    if ($collect == 1)
    {
	if (/^(n|[cY][0-9]):/) { push @line_accum, $_; }
	if (/^# exp_E ([0-9.]+)/)
	{
	    push @line_accum, $_;
	    $score = $1;
	    $collect = 0;

	    if (($ct<=$cx) || ($score < ($things[$cx]->[0])))
	    {
		my $ix = "toad";
		if ($ct <= $cx) { $ix = $ct } else { $ix = $cx }
		$things[$ix] = [$score, (join '$',@line_accum)];
		if ($ct >= $cx) { @things = sort {$a->[0] <=> $b->[0]} @things; }
	    }
	    $ct = 1+$ct;
	}		
    }
    if (/^# Size-optimized polynomial/)
    {
	@line_accum = ();
	$collect = 1;
    }
}
close B;

print "# ",join " ",map($_->[0],@things);
print "\n";

$date = `date +%s`;    
for my $u (0..$cx)
{
    my $tt = $things[$cx-$u]->[1];
    $tt = join "\n",(split '\$',$tt);
    print $tt;
    print "\n\n";
}
