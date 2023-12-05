#!/usr/bin/perl
# $ARGV[0] == input file

# MAIN
my $charFill = '.';
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

        #H!: -
        print "line --> <$line>\n";

        while ($line =~ m/(\d+)/g) {
                my ($nr, $right) = ($1, pos($line) - 1);
                my $left = $right - length($nr) + 1;

                #H!: - matched
                print "nr=<$nr>;left=<$left>;right=<$right>\n";

                # 1. Is char left - if present -  asymbol ?
                if ($left >= 1){ # there is a char at left on the same line
                        $left -= 1;
                        unless (substr($line, $left, 1) eq $charFill){ # left is a relevant symbitl, consider the number
                                $sum += $nr;
                                next;
                        }
                }

                # 2. is char at the right  -if present - a symbol ?
                if ($right < length($line) - 1){ # there is a character at the right on the same line
                        $right += 1;
                        unless (substr($line, $right, 1) eq $charFill){ # left is a relevant symbitl, consider the number
                                $sum += $nr;
                                next;
                        }
                }

                # 3. any adjacent symbol un the prev line - if exists ?
                if (($idxLine > 0) and (substr($listLine[$idxLine - 1], $left, $right - $left + 1) =~ /[^$charFill]/)){
                        $sum += $nr;
                        next;
                }

                # 4. any adjacent symbol on the next line - if exist ?
                if ($idxLine < $#listLine and substr($listLine[$idxLine + 1], $left, $right - $left + 1) =~ /[^$charFill]/){
                        $sum += $nr;
                        next;
                }

                #  5. whatever reaches this point is a number that will be ignored from the sum
                print "line at index: <$idxLine> will skip the number: <$nr>; line --><$line>\n";
        }
}

print "sum of relevant numbers ==<$sum>\n";
