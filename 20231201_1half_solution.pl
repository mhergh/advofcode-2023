#!/usr/bin/perl

# $ARGV[0] == input file

if(/^[^\d]*(\d)/){
	$d1=$1;
	if(/(\d)[^\d]*$/){
		$d2=$1
		}
	else{
		$d2=$d1
	};
	$s+="$d1$d2"
};
END{
	print "sum==<$s>\n"
}

# sample runned on hergmar@mhergh-acer4k:~$ where the input is ~/advofcode_real_input_20231201.txt -->
# perl -ne 'if(/^[^\d]*(\d)/){$d1=$1;if(/(\d)[^\d]*$/){$d2=$1}else{$d2=$d1};$s+="$d1$d2"};END{print "sum==<$s>\n"}' advofcode_real_input_20231201.txt
# Output:
# sum==<54239>
