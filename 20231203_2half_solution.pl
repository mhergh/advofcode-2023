#!/usr/bin/perl
# $ARGV[0] == input file

# SUB
my @adjPartNr = ();
sub getAdjPartNr{ # psuh tot the @adjPartNr all number adjacent to the position in string
        my ($line, $position) = @_; # position is epected to be a valid positive offset of a char from the string !!!
        my ($left, $middle, $right) = (substr($line, 0, $position), substr($line, $position, 1), substr($line, $position + 1));
        $left =~ s/^.*?(\d*)$/$1/;
        $right =~ s/^(\d*).*/$1/;
        if($middle =~ /^\d+$/){
                push(@adjPartNr, $left . $middle . $right); # single adjacency
                return;
        }
        # midle is not a number, therefore push individual adjacencies  if they are non-empty
        push(@adjPartNr, $left) if $left;
        push(@adjPartNr, $right) if $right;
}

# MAIN
my $sum=0;

# slurp file
open(my $inp, '<', $ARGV[0]) or die "Failed to open $ARGV[0]: $!\n";
my @listLine = (<$inp>);
chomp(@listLine);
close($inp);

#H!: - here
print join("\n", 'start-->', @listLine, '<--end')."\n";

foreach my $idxLine (0..$#listLine){
        my $line = $listLine[$idxLine];

        while ($line =~ /(\*)/g) {
                my $position = pos($line) - 1;
                @adjPartNr = ();

                getAdjPartNr($listLine[$idxLine - 1], $position) if $idxLine > 0; # load adjacencies from the prev. line
                getAdjPartNr($listLine[$idxLine + 1], $position) if $idxLine < $#listLine; # load adjacencies from the next. line
                getAdjPartNr($line, $position); # load adjacencies from the current line

                if($#adjPartNr == 1){
                        $sum += $adjPartNr[0] * $adjPartNr[1];
                } else {
                        print "ignored * in position=<$position> has adjacencies: <" . join('|', @adjPartNr) .">; line=<$line>\n";
                }
        }
}

print "sum of gear ratios==<$sum>\n";
