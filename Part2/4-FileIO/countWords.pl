#!/usr/bin/env perl

use strict;
use warnings;

my $count = 0;
splice @ARGV, 1; #Remove extra parameters
my $name = @ARGV[0] or die "Not enough variables\n"; #Keep the name for later use and ensure it exists

#Loop through all the lines in all the files given as parameters
while (my $line = <>){ 
	$count += () = $line =~ /\w+/g; #Use regex to count the words in a line and add them up
}

#open a file, write the count, close the file
open (my $fout, ">", "out_$name") or die "Couldn't open out_$name\n";
print $fout $count;
close $fout;

print "The created file is out_$name, and it contains:\n $count\n";