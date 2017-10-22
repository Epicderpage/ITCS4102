#!/usr/bin/env perl

use strict;
use warnings;

#Take in input
$_ = $ARGV[0] or die "Not enough arguments. Expected string of parenthetic characters.\n";

#Loop and remove each matched pair
while (1){
	#If we can match a pair, remove it
	if (s/(\{\}|\[\]|\(\))//xs){
		#If the string is empty its balanced
		if ($_ eq ''){
			print "Balanced!\n";
			last;
		}
	} else {
		#If we can't match then the string is unbalanced
		print "Unbalanced\n";
		last;
	}
}