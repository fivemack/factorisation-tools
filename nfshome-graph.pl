#!/usr/bin/perl -w
use strict;

my $colct;

my @now = localtime;
my $tag = $now[3]; my $monat = $now[4]+1; my $jahr = $now[5]+1900;
my $mglob = sprintf("%02d",$monat);
my $fglob=$jahr.$mglob;
my $fglob2="";
if ($tag < 15)
{
    if ($monat != 1)
    {
	$fglob2=$jahr.sprintf("%02d",$monat-1);
	$fglob = $jahr.$mglob;
    }
    else
    {
	$fglob2=($jahr-1)."12";
    }
}

for my $toplevel ("d","e")
{
    my $output;
    my %ocols; my $next_ocol = 0;
    my @projnames; $projnames[0]="Unix time";

    my @efiles = glob("$toplevel.$fglob*");
    my @efiles2 = glob("$toplevel.$fglob2*");
    @efiles=(@efiles,@efiles2);
    for my $f (@efiles)
    {
	my $oline;
	$f =~ m/[de]\.([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})/;
	my ($Y,$M,$D,$h)=($1,$2,$3,$4);
	my @stat = stat $f; my $mt = $stat[9];
	
	my $content;
	{
	    local $/ = undef;
	    open A,"< $f";
	    $content = <A>;
	    close A;
	}
	# an extra newline got into the files at some point
	$content =~ tr#\n# #;
	$content =~ m#Now sieving</h2>.*?(<table .*?</table>)#;
	my $sievetab = $1;
	my @rows = split "<tr>",$sievetab;
	for my $j (0..$#rows)
	{
	    $rows[$j] =~ s#</(table|tr)>##g;
#	    print "Inspecting row $rows[$j]\n";
	    my @cols = split "<td[^>]*>",$rows[$j];
#	    print "It has",$#cols," columns\n";
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
		    $oline->[$ocols{$project}]=$rels;
		}
	    }
	}
	if (defined $oline)
	{
	    $output->{$mt}=$oline;
	}
    }

# rewrite project names to come out right in gnuplot
    for my $pn (@projnames)
    {
	$pn =~ s/__/.../g;
	if ($pn =~ m/^([0-9.]*)_([0-9]*)(_minus1|m1)$/) { $pn = "$1^$2-1"; }
	elsif ($pn =~ m/GW_([0-9]*)_([0-9]*)/) { $pn = "$2*$1^$2-1"; }
	elsif ($pn =~ m/GC_([0-9]*)_([0-9]*)/ or 
	       $pn =~ m/^([0-9]+)_([0-9]+)p$/) { $pn = "$2*$1^$2+1"; }
	elsif ($pn =~ m/C([0-9]*)_([0-9]*)_([0-9]*)/) { $pn = "C$1 from $2^$3+$3^$2"; }
	elsif ($pn =~ m/W_([0-9]*)/) { $pn = "$1*2^$1-1"; }
	elsif ($pn =~ m/C_([0-9]*)/) { $pn = "$1*2^$1+1"; }
	elsif ($pn =~ m/(^[0-9]{5})_([0-9]*)$/)
	{
	    if (substr($1,2,1) eq substr($1,1,1))
	    {
		$pn = "near-repdigit $2 digits pattern $1";
	    }
	    else
	    {
		$pn = "near-repdigit ".(2*$2+1)." digits pattern $1";
	    }
	}
	elsif ($pn =~ m/^([0-9]+)_([0-9]+)_([0-9]+)m$/)
	{ $pn = "$1*$2^$3-1"; }

	my $upn = ""; my $ss = 0;
	for my $ci (0..length($pn))
	{
	    my $c = substr($pn,$ci,1);
	    if ($ss == 1 && !($c =~ m/[0-9]/)) { $ss=0; }
	    if ($c eq "^") { $ss = 1; }
	    else
	    {
		if ($ss==1) { $upn .= "^"; }
		$upn .= $c;
	    }
	}
	$pn=$upn;
    }
    
    open AUS,"> parse-$toplevel.aus";
    print AUS join ",",@projnames,"\n";
    my $num_ocols = $next_ocol-1;
    my $firstline = 1; my @prev; my $t0 = -1;
    for my $t (sort {$a <=> $b} keys %{$output})
    {
	if ($firstline != 1 && defined $output->{$t})
	{
	    my @delta = @{$output->{$t}};
	    for my $v (0..$num_ocols)
	    {
		if (!defined $delta[$v]) { $delta[$v] = 0; }
		if (defined $prev[$v])
		{
		    if ($delta[$v] != 0)
		    {
			$delta[$v] -= $prev[$v];
		    }
		}
		$delta[$v] /= ($t-$t0);
	    }
	    print AUS $t,",",join ",",@delta,"\n";
	}
	@prev = @{$output->{$t}}; $t0 = $t;
	$firstline = 0;
    }
    close AUS;
# and generate the graph file, because they need to know the count
# of entries on the line
# but count the timestamp, and gnuplot starts counting at 1
    $num_ocols += 2;
    open GRAPH,"> graph-$toplevel.gpl";
    print GRAPH <<END;
set title "Relations per second"
set xdata time
set timefmt "%s"
set datafile separator ","
set terminal png size 1600,1200 enhanced truecolor font 'Verdana,9'
set output "RPS-$toplevel.png"
set ylabel "Relations per second"
set xlabel "Date"
set yrange [0:10<*]
set pointsize 0.8
set format x "%d/%m"
set border 11
set xtics out
set tics front
set key below
plot \\
  for [i=2:$num_ocols:1] \\
    "parse-$toplevel.aus" using 1:(sum [col=i:$num_ocols] column(col)) \\
      title columnheader(i) \\
      with filledcurves x1 lc (i-1)\%6
END
    close GRAPH;
}

