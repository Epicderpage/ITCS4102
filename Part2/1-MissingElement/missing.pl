#!/usr/bin/env perl

use strict;
use warnings;
use List::Util qw(shuffle);

# Takes in an array in the format # # # or generates an array
my @nums = (@ARGV)? @ARGV : (0..16);

# Print out the array
print "@nums\n";

# Sum the array
my $sum1 = eval join '+', @nums;

# Shuffle the array using a built in subroutine
@nums = shuffle @nums;

# Delete an element from an array
splice @nums, rand(scalar @nums), 1;

# Print the modified array
print @nums == 0 ? "[]\n" : "@nums\n";

# Calculate the missing element (old - new) = missing
print "Missing: ".($sum1 - (@nums == 0 ? 0 : (eval join '+', @nums)))."\n";