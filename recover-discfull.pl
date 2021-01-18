#!/usr/bin/perl

sub find_rp($$)
{
    # gnfs_lasieve4I16e outputs the special-Q last
    my ($u,$v)=@_;
    my ($aa,$bb,$cc)=split ":",$u;
    my @xp = split ",",$bb;
    return hex($xp[-1]);
}

@a=(48,188,197,198,210,215,225);
for my $dir (@a)
{
    my @files = glob "$dir/*.rels";
    for my $fn (@files)
    {
	$fn =~ /([0-9]+)\.rels/; my $fx = $1;
	open A,"< $fn";
	my $file_content = do { local $/; <A> };
	my @pibble = split "\0+",$file_content;
	if ($#pibble != 0)
	{
	    my @fg = split "\n",$pibble[0];
	    my @bg = split "\n",$pibble[1];
#	    print "FN=",$fn,"\n";
#	    print $#fg," ", $#bg,"\n";
	    my ($gap_start, $gap_end);

	    if ($#fg > 10)
	    {
		my $l1 = $fg[-2];
		my $l2 = $fg[-3];
		$gap_start = find_rp($l1,$l2);
	    }
	    else { $gap_start = $fx*10000; }

	    if ($#bg > 10)
	    {
		$gap_end = find_rp($bg[1],$bg[2]);
	    }
	    else { $gap_end = (1+$fx)*10000; }
	    
	    #	    print $fn," ",$fx," ",$gap_start," ",$gap_end,"\n";
	    my $gap_len = $gap_end-$gap_start+1;
	    print "/home/nfsworld/gnfs-batalov/gnfs-lasieve4I16e snfs -r -o $fn"."b -f $gap_start -c $gap_len\n";
	}
    }
}

