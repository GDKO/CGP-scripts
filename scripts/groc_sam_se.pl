#!/usr/bin/env perl

# Author: Georgios Koutsovoulos

use strict;
use warnings;

my $list_file = $ARGV[0];
my $sam_file = $ARGV[1];
my $stats_file = "$sam_file".".stats";

open (LIST,"$list_file");

my %ids;

while (<LIST>) {

chomp;
$ids{$_}=1;
}


close LIST;

open (SAM,"$sam_file");
open (STATS,">$stats_file");
open (READONE, ">read_1.fq");

my $read_count=0;
my $read_exclude=0;
my $read_include=0;
my $read_unmapped=0;

my $print_fq;


while (my $line_f=<SAM>) {

next if $line_f =~ /^\@/;

$print_fq=1;
$read_count++;

if ($read_count % 1000000 == 0) {
	print "Processed $read_count reads\n";
}

my @fp=split(/\t/,$line_f);

if ($fp[1]&16) {

	$fp[9]  =~ tr/atgcATGC/tacgTACG/;
	$fp[9] 	=  reverse($fp[9]);
	$fp[10] =  reverse($fp[10]);
}


my $fid=0;
if (exists $ids{$fp[2]}) {$fid=1}


if ($fid>0) {
	
	$read_exclude++;
	$print_fq=0;	
	}

elsif ($fp[2] eq "*") {

        $read_unmapped++;
        }

else {

	$read_include++;
	}

if ($print_fq) {

print READONE "\@$fp[0]/1\n$fp[9]\n\+\n$fp[10]\n";

}

}

close READONE;

close SAM;

print "Processed $read_count reads\n";

print STATS "Total reads: $read_count\n";

my $rounded = sprintf("%.2f", ($read_exclude*100)/$read_count);
print STATS "Exclude: $read_exclude ($rounded%)\n";

$rounded = sprintf("%.2f", ($read_include*100)/$read_count);
print STATS "Include: $read_include ($rounded%)\n";

$rounded = sprintf("%.2f", ($read_unmapped*100)/$read_count);
print STATS "Unmapped | Unmapped: $read_unmapped ($rounded%)\n";

close STATS;
