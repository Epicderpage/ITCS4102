#!/usr/bin/env perl

use strict;
use warnings;

my $count = 0;
splice @ARGV, 1; # Remove extra arguments
# Keep the name for later use and ensure it exists
my $name = $ARGV[0] or die "Not enough arguments. Expected filename.\n";

# Loop through all the lines in the file given as an argument
while (my $line = <>){
  # Use regex to count the words in a line and add them up
  $count += () = $line =~ /\w+/g;
}

# Open a file, write the word count, and close the file
open (my $fout, ">", "out_$name") or die "Couldn't open out_$name\n";
print $fout $count;
close $fout;

print "The created file is out_$name, and it contains:\n $count\n";