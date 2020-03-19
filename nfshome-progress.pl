#!/usr/bin/perl -w
use strict;

my $colct;
my @resultat;

sub commify($)
{
    my ($n) = @_;
    my $n0 = $n;
    my $m = "";
    while (length($n)>3)
    {
	$m = ",".substr($n,-3,3).$m;
	$n = substr($n,0,-3);
    }
    $m = $n.$m;
    return $m;
}

for my $toplevel ("d","e")
{
    my @projnames; $projnames[0]="Unix time";

    my $output;
    my %ocols; my $next_ocol = 0;
    
    my @efiles = glob("$toplevel.2020*");
    for my $f (@efiles)
    {
	my $oline;
#	$f =~ m/[de]\.([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})/;
#	my ($Y,$M,$D,$h)=($1,$2,$3,$4);
	my @stat = stat $f; my $mt = $stat[9];
	
	my $content;
	{
	    local $/ = undef;
	    open A,"< $f";
	    $content = <A>;
	    close A;
	}

	$content = join "@",(split "\n",$content);
	
	$content =~ m#(<table.*?/table>)#;
	my $sievetab = $1;
	my @rows = split "<tr>",$sievetab;
	for my $j (0..$#rows)
	{
	    $rows[$j] =~ s#</(table|tr)>##g;
	    my @cols = split "<td[^>]*>",$rows[$j];
	    for my $i (0..$#cols)
	    {
		$cols[$i] =~ s#</td>##g;
#	    print "$j $i $cols[$i]\n";
	    }
	    if ($j>=2)
	    {
		my ($project,$rels)=($cols[2],$cols[11]);
		$rels =~ s/,//g;
		if ($rels > 0)
		{
#	    print $mt," ",$cols[2]," ",$cols[11],"\n";
		    if (! defined $ocols{$project})
		    {
			$ocols{$project} = $next_ocol++;
			$projnames[$next_ocol]=$project;
		    }
#		    print "ng ",$f, " ", $project," ",$rels," ",$ocols{$project},"\n";
		    $oline->[$ocols{$project}]=$rels;
		}
	    }
	}
	$output->{$mt}=$oline;
    }

    my @toad = sort keys %{$output};
    my $now = $output->{$toad[-1]};
    my $then = $output->{$toad[-2]};
    my $ncol = $next_ocol;
    for my $u (0..$ncol)
    {
	if (defined $now->[$u] and defined $then->[$u])
	{
	    my $progress;
	    if ($now->[$u] == $then->[$u]) { $progress = "done"; }
	    else { $progress = "+".sprintf("%6.2g",($now->[$u] - $then->[$u])); }
	    $progress =~ s/ //g;
	    my $pn = $projnames[$u+1];
	    $pn =~ s/ /_/g;
	    push @resultat,["[".$toplevel."]", $pn, commify($now->[$u]), $progress];
	}
    }
}

my @rcw=(0,0,0,0);
for my $u (0..3)
{
    for my $q (@resultat)
    {
	my $l = length($q->[$u]);
	if ($l > $rcw[$u]) { $rcw[$u]=$l; }
    }
}

for my $q (@resultat)
{
    for my $u (0..3)
    {
	my $l = length($q->[$u]);
	my $j = " "x($rcw[$u]-$l);
	if ($u != 2)
	{
	    print $q->[$u],$j," ";
	}
	else
	{
	    print $j,$q->[$u]," ";
	}
    }
    print "\n";
}
