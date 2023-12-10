#!/usr/bin/perl
use strict;
use warnings;

# $ARGV[0] == input file 

# SUB
# the maps - are arrays numerically ascending sorted by the second element value: (50, 98, 2) --> [50, 98, 99, 51]; ([50, 98, 99, 51], ...) where [50, 98, 99, 51] == [<destination start>, <source start>, <source end>, <destination end>]
# this mapping is f(source + offset) = destination + offset if offset <= <source end> or source + offset if no mapping found
# all the maps are mathematical functions fi:N -> N and they are constructed as bijections therefore their composition fChain:N -> N is also a bijection
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

# returns the list of sources start for the provided func
sub getFuncSourceStarts($){
	my ($func) = @_;
	my @sourceStart = ();
	foreach(@{$func}){
		# [<destination start>, <source start>, <source end>, <destination end>] == ($_->[0], $_->[1], $_->[2], $_->[3])
		push(@sourceStart, $_->[1]);
	}
	return @sourceStart;
}

# returns the list of destinations start for the provided func
sub getFuncDestinationStarts($){
	my ($func) = @_;
	my @destinationStart = ();
	foreach(@{$func}){
		# [<destination start>, <source start>, <source end>, <destination end>] == ($_->[0], $_->[1], $_->[2], $_->[3])
		push(@destinationStart, $_->[0]);
	}
	return @destinationStart;
}

# returns destination for a func and source
sub applyFunc($$){
	my ($func, $source) = @_; # $func is a ref to one of the @f1, ... @f7 $source is the integer to be mapped
	foreach(@{$func}){
		# [<destination start>, <source start>, <source end>, <destination end>] == ($_->[0], $_->[1], $_->[2], $_->[3])
		last if $source < $_->[1]; # because entries are sorted by source start, no mapped interval can match
		# if I am here, means $source >= $_->[1]
		next unless $source <= $_->[2]; # skip to the next interval because $source is outside
		# if I am here, means $_->[1] <= $source <= $_->[2] --> I can map
		return $_->[0] + $source - $_->[1];
	}
	return $source; # not mapped aka destination == source
}

# returns source for a func^(-1) (the inverse of func) and destination
sub applyFunc_1($$){
	my ($func, $destination) = @_; # $func is a ref to one of the @f1, ... @f7 $source is the integer to be mapped
	foreach(@{$func}){ # the search for the corresponding source may reach the entire array because sorting made on source
		# [<destination start>, <source start>, <source end>, <destination end>] == ($_->[0], $_->[1], $_->[2], $_->[3])
		return $_->[1] + $destination - $_->[0] if $_->[0] <= $destination and $destination <= $_->[3];
	}
	return $destination; # not mapped aka destination == source
}

# returns the source list for a func^(-1) (the inverse of func) and destination list
sub applyFunc_1_4List($@){
	my ($func, @destination) = @_; # $func is a ref to one of the @f1, ... @f7 $source is the integer to be mapped
	my @source = ();
	foreach(@destination){
		push(@source, applyFunc_1($func, $_));
	}
	return @source;
}

# returns an array with all primary sources (aka seeds) that are source interval starts (interval == range)
sub gatherAllPrimarySourceIntervalStarts(){
	my @primarySourceIntervalStart = ();
	
	# 1. init - get the source starts for f7
	push(@primarySourceIntervalStart, getFuncSourceStarts(\@f7));
	
	# 2. parse funcs upstream
	foreach(\@f6, \@f5, \@f4, \@f3, \@f2, \@f1){
		# 2.1. interpret gathered as destinations for f6 and get the corresponding f6 source starts
		@primarySourceIntervalStart = applyFunc_1_4List($_, @primarySourceIntervalStart);
		# 2.2. append the original sources for f6
		push(@primarySourceIntervalStart, getFuncSourceStarts($_));
	}

	return @primarySourceIntervalStart;
}

sub applyFuncChain(@){
	my ($source) = @_;
	my $res = $source;
	my $idx = 1;
	foreach(
		'seed-to-soil',
		'soil-to-fertilizer',
		'fertilizer-to-water',
		'water-to-light',
		'light-to-temperature',
		'temperature-to-humidity',
		'humidity-to-location'){
			my $inp = $res;
			$res = applyFunc($mapFunc2Array{$_}, $res);
			$idx += 1;
	}
	return $res;
}

# min related subs
# f == the entire composition == f7(f6(f5(...(x)))); y = f(x)
my @minPoint = (); # = ([x, y], ...) min relative points for f: y = f(x); numerically ascending sorted by x
sub setupMinPoint(){
	# 1. gather all primary sources starts and setup the minPoint structure
	my @allPrimarySourceIntervalStarts = gatherAllPrimarySourceIntervalStarts();
	foreach(@allPrimarySourceIntervalStarts){
		push(@minPoint, [$_, applyFuncChain($_)]); # [x, y]
	}

	# 2. sort ascending by y values
	@minPoint = sort {$a->[1] <=> $b->[1]} @minPoint;
}

# CALL THIS IMEDIATELY AFTER PARSING INPUT !!!
sub completePreparations(){
	# 1. sort all @f<index> functions on source == element with index 1 ...
	foreach (values(%mapFunc2Array)){
			@{$_} = sort {$a->[1] <=> $b->[1]} @{$_};
		}

	# 2. min points
	setupMinPoint();
}

# returns the min y for the given source interval
sub getMinValue4Interval($$){
	my ($sourceStart, $sourceEnd) = @_;
	# 1. the min is provided by the interval start if no other min point present in the source interval
	my $min = applyFuncChain($sourceStart);

	# 2. set the min if any min points in the interval having y < min
	foreach(@minPoint){
		my ($minPointSource, $minPointValue) = ($_->[0], $_->[1]);
		if($sourceStart <= $minPointSource and $minPointSource <= $sourceEnd){
			$min = $minPointValue if $minPointValue < $min;
			last; # beause the minPoint is sorted, the first match will do
		}
	}

	return $min;
}

# MAIN

my $minAbsoluteLocationNr = -1;
my @seedInterval = ();

# 1. parse the input file and initialize structures
my $ref2f = undef;
my %hSourceStart =(); # to not insert them multiple times
open(my $inp, '<', $ARGV[0]) or die "Failed to open $ARGV[0]: $!\n";
while(<$inp>){
	chomp;
	if(/^\s*(\d+)\s*(\d+)\s*(\d+)\s*$/){ # mapping for the current function and initialise the corresponding min point
		# [<destination start>, <source start>, <source end>] == ($_->[0], $_->[1], $_->[2])
		my ($destinationStart, $sourceStart, $sourceEnd, $destinationEnd) = ($1, $2, $2 + $3 - 1, $1 + $3 - 1);
		push(@{$ref2f}, [$destinationStart, $sourceStart, $sourceEnd, $destinationEnd]);
		next;
	}
	if(/^\s*(.*?)\s*map/){ # func definition
		$ref2f = $mapFunc2Array{$1};
		next;
	}
	next if /^\s*$/; # skip content-empty lines
	if(/^\s*seed[\s:]*(.*?)\s*$/){ # seeds ranges - will be expanded to individual seeds and pushed into the list
		my ($seedRanges) = ($1);
		while($seedRanges =~ /\s*(\d+)\s+(\d+)\s*/g){
			my ($seedStart, $seedEnd) = ($1, $2 + $1 - 1);
			push(@seedInterval, [$seedStart, $seedEnd]);
		}
		next; 
	}
	print "ignored unrecognized input line: <$_>\n";
}

# 2. finalize
completePreparations();

# 3. this time the solution builds on domain input contiguity of any function involved

# 4. parse the seed intervals, get their location and save if it is the minimum
foreach(@seedInterval){
	my $minRelLocationNr = getMinValue4Interval($_->[0], $_->[1]);
	$minAbsoluteLocationNr = $minRelLocationNr if $minRelLocationNr < $minAbsoluteLocationNr or $minAbsoluteLocationNr < 0;
}

close($inp);

print "minPoint size: <$#minPoint>; absolute minimum location number==<$minAbsoluteLocationNr>\n";
