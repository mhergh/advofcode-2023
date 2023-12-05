#!/usr/bin/perl
# $ARGV[0] == input file

# MAIN
my $sumOfPowers=0;

open(my $inp, '<', $ARGV[0]) or die "Failed to open $ARGV[0]: $!\n";

while(<$inp>){
  chomp;

  if(/^\s*(?:Game|)\s*(\d+)\s*:\s*(.*)/i){
          my ($idGame, $subsets) = ($1, $2);
          my %max=('red'=>1,'green'=>1,'blue'=>1); # because of multiplication any min has to be 1
          foreach my $subset (split(/\s*;\s*/, $subsets)){
                  foreach my $component (split(/\s*,\s*/, $subset)){
                          if($component =~ /^(\d+)\s*([a-z]+)$/i){
                                  my ($ctr, $color) = ($1, $2);
                                  if (exists($max{$color}) and $ctr>$max{$color}){
                                          $max{$color} = $ctr;
                                  }
                          }
                  }
          }
          my $power = 1;
          foreach (values(%max)){
                  $power *= $_;
          }
          print "powers <" . join(':', %max) . "> power of Game == <$power>; <$_>\n";
          $sumOfPowers += $power;
  }
}

print "sum of powers ==<$sumOfPowers>\n";
