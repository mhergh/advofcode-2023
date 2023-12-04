# $ARGV[0] == input file - this is just an extension of the 1half - but the part from 1half has been slightly optimized and a little more "perl-ish" edited ...

BEGIN{
  %m=("zero"=>0,"one"=>1,"two"=>2,"three"=>3,"four"=>4,"five"=>5,"six"=>6,"seven"=>7,"eight"=>8,"nine"=>9,);
  $reDigit=join("|", sort(keys(%m)))
}

END{
	print "sum==<$s>\n"
}

#MAIN
open(my $inp, '<', $ARGV[0]) or die "Failed to open $ARGV[0]: $!\n";

while(<$inp>){
  # 1. translate only the relevant digitwords first
  s/^[^\d]*?($reDigits)/$m{$1}/i;
  s/($reDigits)[^\d]*?$/$m{$1}/i;
  # 2. extract the relevant number from the line and add it to the sum
  if(/^[^\d]*(\d)/){
  	$d1=$1;
    $d2=$1 if /(\d)[^\d]*$/;
  	$s+="$d1$d2"
  };
}

# sample runned on hergmar@mhergh-acer4k:~$ where the input is ~/advofcode_real_input_20231201.txt -->
# perl -ne 'if(/^[^\d]*(\d)/){$d1=$1;if(/(\d)[^\d]*$/){$d2=$1}else{$d2=$d1};$s+="$d1$d2"};END{print "sum==<$s>\n"}' advofcode_real_input_20231201.txt

# perl -ne 'if(//){};END{print "sum=<$s>\n"}' advofcode_real_input_20231201.txt

# Output:
# sum==<54239>

# perl -e 's/\d/-/g' <file>
