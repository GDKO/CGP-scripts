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
open (READTWO, ">read_2.fq");

my $read_pairs_count=0;
my $read_pairs_exclude_exclude=0;
my $read_pairs_exclude_unmapped=0;
my $read_pairs_include_unmapped=0;
my $read_pairs_exclude_include=0;
my $read_pairs_unmapped_unmapped=0;
my $read_pairs_include_include=0;

my $print_fq;


while (my $line_f=<SAM>) {

next if $line_f =~ /^\@/;

$print_fq=1;
my $line_s=<SAM>;
$read_pairs_count++;

if ($read_pairs_count % 10000000 == 0) {
	print "Processed $read_pairs_count pairs\n";
}

my @fp=split(/\t/,$line_f);
my @sp=split(/\t/,$line_s);

if ($fp[1]&16) {

	$fp[9]  =~ tr/atgcATGC/tacgTACG/;
	$fp[9] 	=  reverse($fp[9]);
	$fp[10] =  reverse($fp[10]);
}

if ($sp[1]&16) {

	$sp[9]  =~ tr/atgcATGC/tacgTACG/;
	$sp[9]  =  reverse($sp[9]);
        $sp[10] =  reverse($sp[10]);
}

my $fid=0;
if (exists $ids{$fp[2]}) {$fid=1}

my $sid=0;
if (exists $ids{$sp[2]}) {$sid=1}


if ($fid>0 && $sid>0) {
	
	$read_pairs_exclude_exclude++;
	$print_fq=0;	
	}

elsif (($sp[2] eq "*") && ($fp[2] eq "*")) {

        $read_pairs_unmapped_unmapped++;
        }


elsif (($fid>0 && ($sp[2] eq "*")) || (($fp[2] eq "*") && $sid>0)) {

	$read_pairs_exclude_unmapped++;
	$print_fq=0;
	}

elsif (($fid==0 && ($sp[2] eq "*")) || (($fp[2] eq "*") && $sid==0)) {

        $read_pairs_include_unmapped++;
        }


elsif (($fid>0 && $sid==0) || ($fid==0 && $sid>0)) {
	
	$read_pairs_exclude_include++;
	}

else {

	$read_pairs_include_include++;
	}

if ($print_fq) {

print READONE "\@$fp[0]/1\n$fp[9]\n\+\n$fp[10]\n";
print READTWO "\@$sp[0]/2\n$sp[9]\n\+\n$sp[10]\n";

}

}

close READONE;
close READTWO;
close SAM;

print "Processed $read_pairs_count pairs\n";

print STATS "Total pairs: $read_pairs_count\n";

my $rounded = sprintf("%.2f", ($read_pairs_exclude_exclude*100)/$read_pairs_count);
print STATS "Exclude | Exclude: $read_pairs_exclude_exclude ($rounded%)\n";

$rounded = sprintf("%.2f", ($read_pairs_exclude_unmapped*100)/$read_pairs_count);
print STATS "Exclude | Unmapped: $read_pairs_exclude_unmapped ($rounded%)\n";

$rounded = sprintf("%.2f", ($read_pairs_exclude_include*100)/$read_pairs_count);
print STATS "Exclude | Include: $read_pairs_exclude_include ($rounded%)\n";

$rounded = sprintf("%.2f", ($read_pairs_include_include*100)/$read_pairs_count);
print STATS "Include | Include: $read_pairs_include_include ($rounded%)\n";

$rounded = sprintf("%.2f", ($read_pairs_include_unmapped*100)/$read_pairs_count);
print STATS "Include | Unmapped: $read_pairs_include_unmapped ($rounded%)\n";

$rounded = sprintf("%.2f", ($read_pairs_unmapped_unmapped*100)/$read_pairs_count);
print STATS "Unmapped | Unmapped: $read_pairs_unmapped_unmapped ($rounded%)\n";

close STATS;
