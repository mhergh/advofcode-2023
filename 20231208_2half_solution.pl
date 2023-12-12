#!/usr/bin/perl
use strict;
use warnings;

# $ARGV[0] == input file 

my @position = (); # simultaneous positions - therefore a list
my @cycleLength = (); # how many steps every single state needs to reach a final state
my $stepCount = 0;

# SUB

sub lcm($$) {
    my ($a, $b) = @_;
    my $gcd = gcd($a, $b);
    return ($a * $b) / $gcd;
}

sub gcd($$); # avoid "called to early to check prototoype" because the recursive call within gcd()
sub gcd($$) {
	my ($a, $b) = @_;
    if ($b == 0) {
        return $a;
    } else {
        return gcd($b, $a % $b);
    }
}

sub gcdVector(@);
sub gcdVector(@){
	return gcd(shift, shift) if $#_ == 1;
	push(@_, gcd(pop, pop));
	return gcdVector(@_);
}

sub lcmVector(@);
sub lcmVector(@){
	return lcm(shift, shift) if $#_ == 1;
	push(@_, lcm(pop, pop));
	return lcmVector(@_);
}

# returns the number of remaining non-final positions after eliminating all final positions from the provided list
sub eliminateFinals($){
	my ($refPosition) = @_;
	return 0 unless @{$refPosition};
	foreach(0..$#$refPosition){
		last if $_ > $#$refPosition;
		if($refPosition->[$_] =~ /Z$/){ #  a final state reached for the array element
			push(@cycleLength, $stepCount);
			splice(@{$refPosition}, $_, 1);
			return 0 if $#$refPosition < 0;
		}
	}
	return $#$refPosition + 1;
}

# MAIN
my $totalWinnings = 0;
my %mapLR = (); # ( AAA => { L => BBB, R => CCC }, ...)
my @move = (); # any entry in the list is one-of: ('L', 'R')
my $idxStep = 0;


# 1. parse the input file and setup structures
open(my $inp, '<', $ARGV[0]) or die "Failed to open $ARGV[0]: $!\n";
while(<$inp>){
	chomp;
	if(/^\s*([A-Z\d]+)[\s=(]+([A-Z\d]+)[,\s]+([A-Z\d]+)/){ # 'AAA = (BBB, BBB)'
		my ($pos, $l, $r) = ($1, $2, $3);
		$mapLR{$pos} = {L => $l, R => $r};
		push(@position, $pos) if $pos =~ /A$/;
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

# 2. print some info
print "simultaneous positions max index: <$#position>\n";

# 3. parse the @move, execute the moves till reaching the <END> == 'ZZZ' State
my $timeStart = time();
my $nCycle = 1;
while(eliminateFinals(\@position)){
	if($idxStep > $#move){
		$idxStep = 0;
		if($nCycle % 100000 == 0){
			my $timeElapsed = time() - $timeStart;
			print "------> cycle#: <$nCycle> ended; step count: <$stepCount>; elapsed secs: <$timeElapsed>; new cycle starts ...\n";
		}
		$nCycle++;
	}
	$stepCount++;
	foreach my $idxIndividualPosition (0..$#position){
		$position[$idxIndividualPosition] = $mapLR{$position[$idxIndividualPosition]}->{$move[$idxStep]};
	}
	$idxStep++;
}

# total steps == lcm(individual number of steps)
my $totalSteps2Finalize = lcmVector(@cycleLength);
print "steps to finalize all at once == <$totalSteps2Finalize>\n";
