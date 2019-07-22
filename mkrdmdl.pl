open A,"< dodgy-lines";
while (<A>)
{
    if (/^([-0-9]*),([-0-9]*):/)
    {
	if ($1 ne "" and $2 ne "")
	{
	    push @tt,"[$1,$2]";
	}
    }
}
my $Tline = "T=[" . (join(",",@tt))."];";
open A,"< refactor-dodgy-msieve-dat-lines.gp";
open B,"> go.gp";
while (<A>)
{
    if (/^#/)
    {
	print B $Tline,"\n";
    }
    else
    {
	print B $_;
    }
}
close A;
close B;
       
