#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper qw(Dumper);

#Process 
our $input = shift;
my @chars = split(//, $input);
my $len = scalar @chars;

#Simple print function for the array 
sub printA {
	foreach my $p (@_){
		print $p;
	}
	print "\n";
}


#Heap's algorithm (B. R. Heap, 1963)
my $i=0;
my @j = (0) x $len;
printA @chars;

while ($i < $len){
	if ($j[$i] < $i){
		if (($i % 2) == 0) {
			@chars[0,$i] = @chars[$i,0];
		} else {
			@chars[$j[$i],$i] = @chars[$i, $j[$i]];
		}
		printA @chars;
		$j[$i]++;
		$i=0;
	} else {
		$j[$i] = 0;
		$i++;
	}
}