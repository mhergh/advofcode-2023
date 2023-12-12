#!/usr/bin/perl
use strict;
use warnings;

# $ARGV[0] == input file 

# SUB

# MAIN
my $totalWinnings = 0;
my %mapLR = (); # ( AAA => { L => BBB, R => CCC }, ...)
my @move = (); # any entry in the list is one-of: ('L', 'R')
my $idxStep = 0;
my $stepCount = 0;
my $position = 'AAA';

# 1. parse the input file and setup structures
open(my $inp, '<', $ARGV[0]) or die "Failed to open $ARGV[0]: $!\n";
while(<$inp>){
	chomp;
	if(/^\s*([A-Z]+)\s*=[\s(]*([A-Z]+)[,\s]+([A-Z]+)\s*/){ # 'AAA = (BBB, BBB)'
		$mapLR{$1} = {L => $2, R => $3};
		next;
	}
	if(/^\s*([LR]+)\s*$/){ # moves - 'LLRLRLR'
		@move = split('', $1);
		next;
	}
	next if /^\s*$/; # skip content-empty lines

	print "ignored unrecognized input line: <$_>\n";
}
close($inp);

# 2. parse the @move, execute the moves till reaching the <END> == 'ZZZ' State
while($position ne 'ZZZ'){
	$idxStep = 0 if($idxStep > $#move);
	$stepCount++;
	$position = $mapLR{$position}->{$move[$idxStep]};
	$idxStep++;
}

print "total steps==<$stepCount>\n";
