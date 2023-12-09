#!/usr/bin/perl
use strict;
use warnings;

# $ARGV[0] == input file 

# SUB
# the maps - are arrays numerically ascending sorted by the second element value: ([50, 98, 2], ...) where [50, 98, 2] == [<destination start>, <source start>, <source end>]
# this mapping is f(source + offset) = destination + offset if offset <= <source end> or source + offset if no mapping found
my @f1 = ();
my @f2 = ();
my @f3 = ();
my @f4 = ();
my @f5 = ();
my @f6 = ();
my @f7 = ();
my %mapFunc2Array = (
	'seed-to-soil'=> \@f1,
	'soil-to-fertilizer'=> \@f2,
	'fertilizer-to-water'=> \@f3,
	'water-to-light'=> \@f4,
	'light-to-temperature'=> \@f5,
	'temperature-to-humidity'=> \@f6,
	'humidity-to-location'=> \@f7,
);

sub applyFunc(@){
	my ($func, $source) = @_; # $func is a ref to one of the @f1, ... @f7 $source is the integer to be mapped
	foreach(@{$func}){
		# [<destination start>, <source start>, <source end>] == ($_->[0], $_->[1], $_->[2])
		last if $source < $_->[1]; # because entries are sorted by source start, no mapped interval can match
		# if I am here, means $source >= $_->[1]
		next unless $source <= $_->[2]; # skip to the next interval because $source is outside
		# if I am here, means $_->[1] <= $source <= $_->[2] --> I can map
		return $_->[0] + $source - $_->[1];
	}
	return $source;
}

sub applyFuncChain(@){
	my ($source) = @_;
	my $res = $source;
	foreach(
		'seed-to-soil',
		'soil-to-fertilizer',
		'fertilizer-to-water',
		'water-to-light',
		'light-to-temperature',
		'temperature-to-humidity',
		'humidity-to-location'){
		$res = applyFunc($mapFunc2Array{$_}, $res);
	}
	return $res;
}

# MAIN
my $minLocationNr=-1;
my @seeds = ();

# 1. parse the input file and build the @f1, ... @f7
my $ref2f = undef;
open(my $inp, '<', $ARGV[0]) or die "Failed to open $ARGV[0]: $!\n";
while(<$inp>){
	chomp;
	if(/^\s*(\d+)\s*(\d+)\s*(\d+)\s*$/){ # mapping for the current function
		push(@{$ref2f}, [$1, $2, $2 + $3 - 1]);
		next;
	}
	if(/^\s*(.*?)\s*map/){ # func definition
		$ref2f = $mapFunc2Array{$1};
		next;
	}
	next if /^\s*$/; # skip content-empty lines
	if(/^\s*seeds[\s:]*(.*?)\s*$/){ # seeds list
		my ($seedsList) = ($1);
		@seeds = split(/\s+/, $seedsList);
		next; 
	}

	print "ignored unrecognized input line: <$_>\n";
}

# 2. sort all @f<index> functions on source == element with index 1 ...
foreach (values(%mapFunc2Array)){
	@{$_} = sort {$a->[1] <=> $b->[1]} @{$_};
}

# 3. parse the seeds, get their location and save if it is the minimum
foreach(@seeds){
	my $locationNr = applyFuncChain($_);
	$minLocationNr = $locationNr if $locationNr < $minLocationNr or $minLocationNr < 0;
}

close($inp);



print "minimum location number==<$minLocationNr>\n";
