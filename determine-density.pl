sub worked($)
{
    my ($density) = @_;
    my @ml;
    system "/home/nfsworld/msieve-svn/trunk/msieve -v -nc1 target_density=$density";
    open K,"< msieve.log";
    while (<K>)
    {
	push @ml, $_;
    }
    foreach (@ml[$#ml-6 .. $#ml])
    {
	if (/filtering wants [0-9]* more relations/) { return 0; }
	if (/matrix probably cannot build/) { return 0; }
    }
    close K;
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

open A, "< /proc/cpuinfo";
my ($ht,$ncpu)=(1,0);
while (<>)
{
    if (/Intel/) { $ht = 2; }
    if (/MHz/) { $ncpu++; }
}

$ncpu /= $ht;

$cmd .= "taskset -c 0-".($ncpu-1)." /home/nfsworld/msieve-svn/trunk/msieve -v -nc2 -t ".$ncpu."; ";
if ($mprime_pid ne "")
{
    $cmd .= "killall -CONT mprime; ";
}
$cmd .= "/home/nfsworld/msieve-svn/trunk/msieve -v -nc3";

print $cmd,"\n\n";

    
