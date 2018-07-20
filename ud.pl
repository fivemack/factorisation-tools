#!/usr/bin/perl
my @x = glob("[0-9]*[0-9][0-9]");
for my $u (@x)
{
    my $age1 = -M $u;
    my $age2 = -M "$u.gpl";
    if ($age1 < $age2)
    {
	system "python /home/nfsworld/aliquot-tools/for_factorization.ath.cx.py $u";
    }
}
