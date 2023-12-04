#!/usr/bin/perl
# $ARGV[0] == input file

# CONFIG
my %max=('red'=>12,'green'=>13,'blue'=>14);
my $sumOfIDs=0;

print "max configuration: ".join(':', %max)."\n";

open(my $inp, '<', $ARGV[0]) or die "Failed to open $ARGV[0]: $!\n";

while(<$inp>){
  chomp;

  # 1. translate only the relevant digitwords first
  if(/^\s*(?:Game|)\s*(\d+)\s*:\s*(.*)/i){
          my ($idGame, $subsets) = ($1, $2);
          my $bIsCountable = 1;
          GAMELOOP: foreach my $subset (split(/\s*;\s*/, $subsets)){
                  foreach my $component (split(/\s*,\s*/, $subset)){
                          if($component =~ /^(\d+)\s*([a-z]+)$/i){
                                  my ($ctr, $color) = ($1, $2);
                                  unless (exists($max{$color}) and $ctr<=$max{$color}){
                                          print "non-countable game because of <$component>: <$_>\n";
                                          $bIsCountable = 0;
                                          last GAMELOOP;
                                  }
                          }
                  }
          }
          if($bIsCountable){
                  # game is countable
                  $sumOfIDs += $idGame;
          }
  }
}

print "sum of Game IDs for possible games ==<$sumOfIDs>\n";
