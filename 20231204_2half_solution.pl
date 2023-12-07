#!/usr/bin/perl
use strict;
use warnings;

# $ARGV[0] == input file 

# SUB
sub getNrCardMatches{ # returns the number of matches for the card on the provided line
	my ($line) = @_; # position is epected to be a valid positive offset of a char from the string !!!
	my ($w, $g) = $line =~ /^[^:]*:\s*(.*?)\s*\|\s*(.*?)\s*$/;
	my %w  = map {$_ => 1} split(/\s+/, $w);
	my $nrMatches = 0;
	foreach (split(/\s+/, $g)){
		$nrMatches += 1 if exists($w{$_});
	}
	return $nrMatches;
}

# MAIN
my $sum=0;
my @card = (); # @card = ([10, 3], [12, 4], ...); # 10 --> number of cards for the index (initialised at 1); 3 --> deep to introduce new cards under this card position

# slurp file
open(my $inp, '<', $ARGV[0]) or die "Failed to open $ARGV[0]: $!\n";
my @listLine = (<$inp>);
chomp(@listLine);
close($inp);

#H!: - here
print join("\n", 'start-->', @listLine, '<--end')."\n";

# 1. initialise @card
foreach my $idxLine (0..$#listLine){
	my $line = $listLine[$idxLine];

	push(@card, [1, getNrCardMatches($line)]);
}

# 2. increase the number of cards according to the matching numbers of each card
foreach my $idxLine (0..$#listLine){
	if($card[$idxLine][1]){
		foreach my $successor (1..$card[$idxLine][1]){
			$card[$idxLine + $successor][0] += $card[$idxLine][0]; 
		}
	}
}

# 3. get the total number of cards and print it
my $nrTotalCards = 0;
foreach (@card){ # $_ is the reference to the internal list with 2 elements: [10, 3] of the current card element
	$nrTotalCards += $_->[0];
}

print "total number of cards==<$nrTotalCards>\n";

