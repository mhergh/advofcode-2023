#!/usr/bin/perl
use strict;
use warnings;

# $ARGV[0] == input file 

my @chain = ();
my @line = ();
my $sum = 0;
my @firstElement = ();

# SUB
# returns 1 if the vector has all elements equal and 0 otherwise; assumed non-empty vector
sub isConstantVector($){
	my ($rVector) = @_;
	foreach(1..$#$rVector){
		return 0 if $rVector->[$_] != $rVector->[0];
	}
	return 1;
}

# transforms the vector in place into the next vector and returns the first element of the original vector
sub reduceFirstElement($){
	my ($rVector) = @_;
	my $firstElement = $rVector->[0];
	foreach(0..$#$rVector - 1){
		$rVector->[$_] = $rVector->[$_ + 1] - $rVector->[$_];
	}
	pop(@{$rVector});
	return $firstElement;
}

# transforms the provided vector till the constant state is reached; first element from every stage is push()-ed into 
sub buildFirstElement($$){
	my ($rVector, $rFirstElement) = @_;
	$#$rFirstElement = -1;
	while(! isConstantVector($rVector)){
		push(@{$rFirstElement}, reduceFirstElement($rVector));
	}
	push(@{$rFirstElement}, reduceFirstElement($rVector)); #  this is the constant value used on layer 1 to generate all vectors based on the left most element
}

# the history of the last element vector
sub getHistory($){
	my ($rFirstElement) = @_;
	my $history = $rFirstElement->[$#$rFirstElement];
	my $idx = $#$rFirstElement - 1;
	while($idx >= 0){
		$history = $rFirstElement->[$idx] - $history;
		$idx--;
	}
	return $history;
}

# MAIN

# 1. parse the input file and setup structures
open(my $inp, '<', $ARGV[0]) or die "Failed to open $ARGV[0]: $!\n";
while(<$inp>){
	chomp;
	if(/^\s*(-?\d+(?:\s+-?\d+){1,})\s*$/){ # '10 13 16 21 30 45' --> negative numbers are also possible
		push(@line, $1);
		next;
	}
	next if /^\s*$/; # skip content-empty lines

	print "ignored unrecognized input line: <$_>\n";
}
close($inp);

# 2. add history for every line to the sum
foreach(@line){
	@chain = split(/\s+/, $_);
	buildFirstElement(\@chain, \@firstElement);
	my $history = getHistory(\@firstElement);
	$sum += $history;
}

print "sum of all history numbers == <$sum>\n";
