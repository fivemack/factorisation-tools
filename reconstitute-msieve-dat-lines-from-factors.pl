open A,"< pong1.aus";
while (<A>)
{
    if (/^\[/)
    {
	my @red = split '\\[',$_;
#	print join "COD",@red,"\n";
	$xy = $red[1];
	$xy =~ m/^(-?[0-9]*), (-?[0-9]*)/; $xy = $1.",".$2;
	my @lf = split ';',$red[3];
	my @rf = split ';',$red[2];

	#	for my $q (0..$#lf) { print $q," ",$lf[$q],"\n"; }
	if ($lf[0] eq "-1, 1") { shift @lf; }
	for my $u (0..$#lf) { $v = $lf[$u]; $v =~ m/^ ?([0-9]+),/; $lf[$u]=sprintf("%x",$1); }
	for my $u (0..$#rf) { $v = $rf[$u]; $v =~ m/^ ?([0-9]+),/; $rf[$u]=sprintf("%x",$1); }

	print $xy,":",(join ",",@lf),":",join(",",@rf),"\n";
    }
}
