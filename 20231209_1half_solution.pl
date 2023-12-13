#!/usr/bin/perl
use strict;
use warnings;

# $ARGV[0] == input file 

my @chain = ();
my @line = ();
my $sum = 0;
my @lastElement = ();

# SUB
# returns 1 if the vector has all elements equal and 0 otherwise; assumed non-empty vector
sub isConstantVector($){
	my ($rVector) = @_;
	foreach(1..$#$rVector){
		return 0 if $rVector->[$_] != $rVector->[0];
	}
	return 1;
}

# transforms the vector in place into the next vector and returns the last element of the original vector
sub reduceLastElement($){
	my ($rVector) = @_;
	foreach(0..$#$rVector - 1){
		$rVector->[$_] = $rVector->[$_ + 1] - $rVector->[$_];
	}
	return pop(@{$rVector});
}

# transforms the provided vector till the constant state is reached; last element from every stage is push()-ed into 
sub buildLastElement($$){
	my ($rVector, $rLastElement) = @_;
	$#$rLastElement = -1;
	while(! isConstantVector($rVector)){
		push(@{$rLastElement}, reduceLastElement($rVector));
	}
	push(@{$rLastElement}, reduceLastElement($rVector)); #  this is the constant value used on layer 1 to generate all vectors based on the left most element
}

# the sum of the last element vector
sub getPrediction($){
	my ($rLastElement) = @_;
	my $sum = 0;
	foreach(@{$rLastElement}){
		$sum += $_;
	}
	return $sum;
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

# 2. add prediction for every line to the sum
foreach(@line){
	@chain = split(/\s+/, $_);
	buildLastElement(\@chain, \@lastElement);
	my $prediction = getPrediction(\@lastElement);
	$sum += $prediction;
}

print "sum of all predicted numbers == <$sum>\n";
