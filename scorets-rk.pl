#!/usr/bin/perl
use strict;

sub meansd($)
{
    my ($dr)=@_;
    my ($n,$s,$ss)=(0,0);
    for my $u (@{$dr}) { if (defined $u) {$n++; $s+=$u; $ss+=$u*$u } }
    my $mu = $s/$n;
    my $ess = $ss/$n;
    return ($mu,sqrt(($ess-$mu*$mu)));
}

# given an input, return the rank array (ie '0' at the place that the smallest entry in the input was)
sub ranks($)
{
    my ($xx)=@_; my $r0=0; my $rk;
    my (@t1,@t2,@t3);
    for my $u (@{$xx})
    {
	push @t2,$r0++;
	push @t1,$u;
    }
    @t3 = sort { $t1[$a] <=> $t1[$b] } @t2;
    # t3[k] is the index of the kth-largest entry in input
    my @t4;
    for my $u (0..$#t3) { $t4[$t3[$u]] = $u; }
#    print "Input ",join " ",@{$xx},"\n";
#    print "t3 ",join " ",@t3,"\n";
#    print "t4 ",join " ",@t4,"\n";
    return \@t4;
}

sub testranks
{
    my @fish=(3,1,4,5,9,2,6);
    print join " ",@fish,"\n";
    my $xf = ranks(\@fish);
    print join " ",@{$xf},"\n";
}

my @files = glob("*.*.t");
# zero-size .t files from jobs-in-progress get ranked randomly
# so strip them out (thanks cjwatson for the golf)
@files = grep { -s } @files;

my (@places,%hplaces);

my ($yield,$time);
for my $u (@files)
{
    $u =~ m/^(.+)\.([0-9]+)\.t/;
    my ($id,$slice)=($1,$2); $hplaces{$slice}=1;
    open A,"< $u";
    my @xlines = <A>;
    close A;
    my @lines;
    for my $v (@xlines) { push @lines, split "\r",$v }
    if ($#lines != -1)
    {
	# restrict to lines containing 'total yield'
	@lines = grep(/^total yield/, @lines);
	
	$lines[1] =~ m/q=([0-9]+) \(/; my $q0 = $1;
	if ($u =~ m/[0-9]*\.([0-9]*)\.t/) { $q0 = $1; } # if the q0 is in the filename
	$lines[-1] =~ m/total yield: ([0-9]*).*q=([0-9]*).*\(([0-9.]+) sec\/rel\)/;
	push @{$yield->{$id}},($1*10000/($2-$q0));
	push @{$time->{$id}},$3;
    }
}

# yield and time vary more by Q sample point than between polynomials
# so (whilst actual yield is a useful measure for later) we want to use
# ranks for scoring
@places = keys %hplaces;

my %rankscore;

for my $place (0 .. $#places)
{
    for my $statn ([$yield,1],[$time,-1])
    {
	my (@sx,@sr);
	for my $poly (keys %{$yield})
	{
	    my $stat = ($statn->[0])->{$poly}->[$place];
	    push @sx,$statn->[1] * $stat; push @sr,$poly;
	}
	@sx = @{ranks(\@sx)};
	for my $v (0..$#sx) { push @{$rankscore{$sr[$v]}},$sx[$v]; }
#	print $place," (",$places[$place],") ",(join "#",@sx);
#	print " : ", (join "+",@sr);
#	print "\n\n";
    }
}

my $rk;
for my $v (keys %rankscore)
{
    my $jj = 0;
    for my $u (@{$rankscore{$v}}) { $jj += $u; }
    $rk->{$v}=$jj;
    print $v," ",$jj," ",(join "+",@{$rankscore{$v}}),"\n";
}

for my $q (sort {$rk->{$b} <=> $rk->{$a}} (keys %{$yield}))
{
    print $q,"\t";
    my @line;
    for my $stat ($yield->{$q}, $time->{$q})
    {
	my ($mu,$sigma) = meansd($stat);
	push @line,($mu,$sigma); 
    }
    push @line, $rk->{$q};
    print sprintf("%.1f",$line[0]),"\t",sprintf("%.1f",$line[1]),"\t";
    print sprintf("%.4f",$line[2]),"\t",sprintf("%.6f",$line[3]),"\t";
    print sprintf("%.1f",$line[4]),"\n";
    
}
