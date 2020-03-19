#!/usr/bin/perl

sub worked($)
{
    my ($density) = @_;

    if (-e "fail.$density") { return 0; }
    if (-e "msieve.dat.cyc.$density") { return 1; }

    my @ml;
    system "/home/nfsworld/msieve -v -nc1 target_density=$density";
    open K,"< msieve.log";
    while (<K>)
    {
	push @ml, $_;
    }
    my $success = 0;
    foreach (@ml[$#ml-6 .. $#ml])
    {
	if (/RelProc/) { $success = 1; }
    }
    close K;
    if ($success == 0) { system "touch fail.$density"; return 0; }
    if (-e "msieve.dat.cyc") { system "cp msieve.dat.cyc msieve.dat.cyc.$density"; }
    return 1;
}

if (! worked(70) ) { die "Not enough relations to get started" }

my $left = 70; 
my $right = 134; my $delta = 64;
while (worked($right)) { $right += $delta; $delta += $delta; }

while ($right - $left > 3)
{
    my $target = ($left+$right)/2;
    if (worked($target)) { $left = $target; } else { $right = $target; }
}

my $mprime_pid = `pidof mprime`;

my $cmd;
if ($mprime_pid ne "")
{
    $cmd = "killall -STOP mprime; ";
}

my $binary = "/home/nfsworld/msieve";
open A, "< /proc/cpuinfo";
my ($ht,$ncpu)=(1,0);
while (<A>)
{
    if (/Intel/) { $ht = 2; }
    if (/MHz/) { $ncpu++; }
    if (/avx512f/) { $binary = "/home/nfsworld/msieve-svn-20190823/msieve-MP-V256-SKL"; }
}

$ncpu /= $ht;

$cmd .= "taskset -c 0-".($ncpu-1)." $binary -v -nc2 -t ".$ncpu."; ";
if ($mprime_pid ne "")
{
    $cmd .= "killall -CONT mprime; ";
}
$cmd .= "/home/nfsworld/msieve -v -nc3";

print $cmd,"\n\n";

    
