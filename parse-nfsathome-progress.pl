#!/usr/bin/perl -w
use strict;

my $colct;

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

my @projnames; $projnames[0]="Unix time";

my ($output,$fn);
my %ocols; my $next_ocol = 0;

for my $toplevel ("d","e")
{
    my @efiles = glob("$toplevel.2019*");
    for my $f (@efiles)
    {
	my $oline;
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
		$project = "[".$toplevel."] ".$project;
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
	$f =~ m/[de]\.([0-9]{10})/;
	$output->{$1}=$oline;
    }
}

# OK, we have now parsed the d.* and e.* files

my @toad = sort keys %{$output};

print join "\nDEBUG",@toad;

for my $q (1..$#toad)
{
    my @resultat;
    
    open B,">> delta-$q";
    my $now = $output->{$toad[$q]};
    my $then = $output->{$toad[$q-1]};
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
	    push @resultat,[$pn, commify($now->[$u]), $progress];
	}
    }
    
    my @rcw;
    for my $u (0..2)
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
		print B $q->[$u],$j," ";
	    }
	    else
	    {
		print B $j,$q->[$u]," ";
	    }
	}
	print B "\n";
    }
}
