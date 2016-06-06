#!/usr/bin/env perl

# Author: Georgios Koutsovoulos

use strict;
use warnings;

my $sam_file=$ARGV[0];

open (SAM,"$sam_file");

while (my $line=<SAM>) {
	
	chomp($line);
	unless ($line =~ /^\@/) {
		
		my @ft=split(/\t/,$line);
		
		if ($ft[2] eq "*") {
	
			print STDOUT "\@$ft[0]/1\n$ft[9]\n\+\n$ft[10]\n"; 
		}

	}

}
