sub hms
{
    my $n = @_[0];
    return sprintf("%d:%02d:%02d",int($n/3600),int(($n%3600)/60),$n%60);
}

my @files = glob("*/msieve.log");
my @acc;
for my $f (@files)
{
    my @ee = ();
    open A,"< $f";
    while (<A>)
    {
	if (/elapsed time ([0-9]+):(..):(..)/) { push @ee, (3600*$1+60*$2+$3); }
    }
    close A;
    if ($#ee != $#acc && $#acc!=-1) { print "Unexpected line count (".(1+$#ee)." where expected ".(1+$#acc)."\n"; }
    for my $i (0..$#ee) { $acc[$i] += $ee[$i]; }
}

print "\n\n";
print join " ",@acc,"\n";
print join " ",(map {hms($_)} @acc),"\n";
