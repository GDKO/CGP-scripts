#!/usr/bin/env perl

# Author: Georgios Koutsovoulos

use strict;
use warnings;

my $sam_file=$ARGV[0];

open (SAM,"$sam_file");

while (my $line=<SAM>) {
	
	chomp;
	unless ($line =~ /^\@/) {
		
		my $line_p=<SAM>;
		my @ft=split(/\t/,$line);
 		my @st=split(/\t/,$line_p);
		
		if ($ft[2] eq "*" && $st[2] eq "*") {
	
			print STDOUT "\@$ft[0]/1\n$ft[9]\n\+\n$ft[10]\n"; 
			print STDERR "\@$st[0]/2\n$st[9]\n\+\n$st[10]\n";
		}

	}

}
