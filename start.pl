use strict;

open A,"< targets";
my %t_index;
while (<A>)
{
    my ($start, $idx) = split " ",$_;
    print $start," ",$idx,"\n";
    $t_index{$start}=$idx;
}

for my $num (keys %t_index)
{
    my $iter;
    # and now we can go and look up the ID
    my $weasel="wget -q -O t2 \"http://www.factordb.com/sequences.php?se=1&eff=2&aq=$num&action=last20\" ";
    system $weasel;
    my $page_for_fullid="fish";
    open B,"< t2";
    while (<B>)
    {
	if (/index.php.id=([0-9]+).>/) {$page_for_fullid=$1}
	if (/^<td>([0-9]+)<\/td>/) {$iter=$1}
    }
    close B;
    print "Last ID is ",$page_for_fullid,"\n\n";
    $weasel = "wget -q -O t3 \"http://www.factordb.com/index.php?id=$page_for_fullid\"";
    system "rm t3";
    system $weasel;
    system "cat t3";
    my $alldigs="fish";
    open C,"< t3";
    while (<C>)
    { if (/query..value=.([0-9]+)/) {$alldigs=$1 }}
    close C;
    my $ndigs=length($alldigs);
    print $num, " ",$iter," ",$t_index{$num}," ",$ndigs," ",$alldigs,"\n\n\n";
    if ($iter == $t_index{$num})
    {
	open D,"> $num";
	print D $alldigs," ",$iter,"\n";
	close D;
    }
    else
    {
	print "MISMATCH\n";
    }
}
