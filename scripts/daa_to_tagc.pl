#!/usr/bin/env perl

# Author: Georgios Koutsovoulos

use strict;
use warnings;

my $tool_name = "diamond";
my $tool_path = `which $tool_name`;
die "No $tool_name command available\n" unless ( $tool_path );

my $uniref_file=$ARGV[0];
my $diamond_file=$ARGV[1];

die "Usage: daa_to_tagc.pl uniref100.taxlist [assembly_se_uniref.daa]\n" unless ( $uniref_file && $diamond_file );

open my $cmd, "diamond view -a $diamond_file |";

my %diamond_hits;
my %hits;
my $i=0;

while (<$cmd>){

	chomp;
	my @columns=split(/\t/,$_);

	$diamond_hits{$i}{"contig"}=$columns[0];

	# Comment this line if you are not working in uniref
	$columns[1]=~ s/UniRef90/UniRef100/;

	$diamond_hits{$i}{"hit"}=$columns[1];
	$diamond_hits{$i}{"bitscore"}=$columns[11];
	$hits{$columns[1]}=1;
	$i++;

}

open (IN,"$uniref_file");

while (<IN>) {

	chomp;
	my @columns=split(/\t/,$_);
	if (exists $hits{$columns[0]}) {
		$hits{$columns[0]}=$columns[1]
	}
}

close IN;

open OUT, ">$diamond_file.tagc";

for (my $k=0;$k<$i;$k++) {

	print OUT "$diamond_hits{$k}{contig}\t$hits{$diamond_hits{$k}{hit}}\t$diamond_hits{$k}{bitscore}\n"
}

close OUT;
