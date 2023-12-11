#!/usr/bin/perl
use strict;
use warnings;

# $ARGV[0] == input file 

# SUB
my %type2Number = (
	5		=> 50, # 'five of a kind'
	41		=> 41, # 'Four of a kind'
	32		=> 32, # 'Full house'
	311		=> 31, # 'Three of a kind'
	221		=> 22, # 'Two pair'
	2111	=> 21, # 'One pair'
	11111	=> 11  # 'High card'
);
sub getSortKey4Hand($){
	my ($hand) = @_;
	my %h = ();
	foreach(split('',$hand)){
		$h{$_}++;
	} # ex. 'ATA9A' --> (A=>3, T=>1, 9=>1); this type is a "three of a kind"; concatenated == '311'
	my $type = '';
	foreach(sort {$b <=> $a} values(%h)){
		$type .= $_;
	}
	# map the key structure (indicates directly the type) to a 2 digit number such that higher type corresponds to a higher number
	# the mapping assumes that we have exactly 5 cards in the hand
	my $typeNumber = $type2Number{$type};
	my $sortKey = $hand;
	$sortKey =~ tr/AKQJT/ZYXWV/;
	$sortKey = "${typeNumber}_$sortKey"; # 32T3K --> 21_32V3Y
	return $sortKey;
}

# MAIN
my $totalWinnings = 0;
my %hand = (); # ( 32T3K => { bid => 765, sk => 21_32V3Y }, ...)

# 1. parse the input file and setup structures
open(my $inp, '<', $ARGV[0]) or die "Failed to open $ARGV[0]: $!\n";
while(<$inp>){
	chomp;
	if(/^\s*([AKQJT2-9]{5})\s*(\d+)\s*$/){ # 32T3K 765; 32T3K --> 21_32V3Y
		my ($handCards, $bid) = ($1, $2);
		$hand{$handCards} = {bid => $bid, sk => getSortKey4Hand($handCards)};
		next;
	}
	next if /^\s*$/; # skip content-empty lines

	print "ignored unrecognized input line: <$_>\n";
}
close($inp);

# 2. parse the %hand ascending sorted and append to the winnings
my $position = 1;
foreach(sort {$hand{$a}->{sk} cmp $hand{$b}->{sk}} keys(%hand)){
	$totalWinnings += $position * $hand{$_}->{bid};
	$position++;
}

print "total winnings==<$totalWinnings>\n";
