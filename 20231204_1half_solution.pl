 perl -pe 'chomp;$p=0;if(/^.*\d+:[ ]*([^|]+?)[ ]*\|[ ]*(.*?)\s*$/){($w, $g)=($1, $2);%w=map {$_=>1} split(/\s+/,$w);foreach(split(/\s+/,$g)){$p=($p>0?$p*=2:1) if exists($w{$_});}$s+=$p;};$_.=" => card points: <$p>; sum points: <$s>\n";END{print "======> sum == <$s>\n"}' advofcode_real_input_20231204.txt