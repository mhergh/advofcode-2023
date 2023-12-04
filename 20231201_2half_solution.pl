#!/usr/bin/perl
# $ARGV[0] == input file

my %m=("zero"=>0,"one"=>1,"two"=>2,"three"=>3,"four"=>4,"five"=>5,"six"=>6,"seven"=>7,"eight"=>8,"nine"=>9,);
my $reDigit=join("|", sort(keys(%m)));
my $sum=0;

open(my $inp, '<', $ARGV[0]) or die "Failed to open $ARGV[0]: $!\n";

while(<$inp>){
  chomp;

  # 1. translate only the relevant digitwords first
  print "before--><$_>\n";
  s/^[^\d]*?($reDigit)/$m{$1}${1}/i;
  s/^(.*)($reDigit)[^\d]*?$/$1$2$m{$2}/i;
  print "after--><$_>\n";

  # 2. extract the relevant number from the line and add it to the sum
  if(/^[^\d]*(\d)/){
    $d1=$1;
    $d2=$1 if /(\d)[^\d]*$/;
    $s+="$d1$d2";
  };
}


print "sum==<$s>\n";
