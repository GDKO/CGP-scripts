#!/usr/bin/env perl

# Author: Georgios Koutsovoulos

use strict;
use warnings;
use Getopt::Long;

my $usage = "
Filters reads based on a list of contaminant sequences (contig IDs, one per line).
Excludes only those read-pairs for which both F and R reads map to contaminant contig.
NOTE: requires sam/bam sorted by readname.

USAGE: groc_sam.pl -l <bad_contigs.list> [-s mapping.sam | -b mapping.bam] [-f <reads_1.fq>] [-r <reads_2.fq>] [-o stats.out] [-h]

OPTIONS:
  --l|list    : list of contigs to exclude reads from [required]
  --s|sam     : sam file
  --b|bam     : bam file (requires samtools in \$PATH) [either -s or -b is required]
  --n|sort    : sort sam/bam by readname before filtering? (requires samtools in \$PATH) [default: no]
  --t|threads : number of sorting/compression threads to run samtools with if -n
  --f|reads_1 : filename to write filtered forward reads [default: reads_1.fq]
  --r|reads_2 : filename to write filtered reverse reads [default: reads_2.fq]
  --z|gzip    : compress reads using gzip? [default: no]
  --k|keep    : keep readsorted files if -n? [default: delete them]
  --o|out     : filename to write stats to [default: reads_filter.stats]
  --h|help    : prints this help message
\n";

## args with defaults
my $stats_file = "read_filter.stats";
my $threads = 1;
my $reads_1 = "reads_1.fq";
my $reads_2 = "reads_2.fq";

## other args
my ($list_file,$sam_file,$bam_file,$sort,$gzip,$keep,$help,$to_delete);

GetOptions (
	'list|l=s'    => \$list_file,
	'sam|s:s'     => \$sam_file,
	'bam|b:s'     => \$bam_file,
	'sort|n'      => \$sort,
	'threads|t:i' => \$threads,
	'reads_1|f:s' => \$reads_1,
	'reads_2|r:s' => \$reads_2,
	'gzip|z'      => \$gzip,
	'keep|k'      => \$keep,
	'out|o:s'     => \$stats_file,
	'help|h'      => \$help,
);

die $usage if $help;
die $usage unless $list_file;

#my $list_file = $ARGV[0];
#my $sam_file = $ARGV[1];
#my $stats_file = "$sam_file".".stats";

open (LIST,"$list_file");

my %ids;

while (<LIST>) {
	chomp;
	$ids{$_}=1;
}
close LIST;

## open from sam or bam
if ($sam_file){
	## sort sam by readname (-n option in samtools sort)
	if ($sort){
		## test for samtools in $PATH
		if (system("samtools sort &>/dev/null")==-1){
                	die "[ERROR] samtools error: is samtools in \$PATH?\n";
        	} else {
			print "Sorting sam file... ";
			## sort sam file and out put to $sam_file.readsorted.sam
			system("samtools sort -@ $threads -n -O sam -T temp -o $sam_file.readsorted.sam $sam_file") or die $!;
			print "done\n";
			open (SAM,"$sam_file.readsorted.sam") or die $!;
			$to_delete = "$sam_file.readsorted.sam";
		}
	} else {
		open (SAM,"$sam_file") or die $!;
	}
} elsif ($bam_file){
	## sort bam by readname (-n option in samtools sort)
	if ($sort){
		if (system("samtools sort &>/dev/null")==-1){
			die "[ERROR] samtools error: is samtools in \$PATH?\n";
		} else {
			print "Sorting bam file... ";
			## sort bam file and output to $bam_file.readsorted.sam
                        system("samtools sort -@ $threads -n -O sam -T temp -o $bam_file.readsorted.sam $bam_file");
                        print "done\n";
                        open (SAM,"$bam_file.readsorted.sam") or die $!;
			$to_delete = "$bam_file.readsorted.sam";
		}

	} else {
		if (system("samtools view &>/dev/null")==-1){
                        die "[ERROR] samtools error: is samtools in \$PATH?\n";
		} else {
			open (SAM, "samtools view -F 3328 $bam_file |") or die $!;
		}
	}
}

open (STATS,">$stats_file");
if ($gzip){
	open (READONE_GZ, "| gzip -c >$reads_1.gz") or die "[ERROR] gzip error: $!\n";
	open (READTWO_GZ, "| gzip -c >$reads_2.gz") or die "[ERROR] gzip error: $!\n";
} else {
	open (READONE, ">$reads_1");
	open (READTWO, ">$reads_2");
}

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
	print "Processed ".commify($read_pairs_count)." pairs\n";
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
	## print to compressed stream if -z
	if ($gzip) {
		print READONE_GZ "\@$fp[0]/1\n$fp[9]\n\+\n$fp[10]\n";
		print READTWO_GZ "\@$sp[0]/2\n$sp[9]\n\+\n$sp[10]\n";
	} else {
		print READONE "\@$fp[0]/1\n$fp[9]\n\+\n$fp[10]\n";
		print READTWO "\@$sp[0]/2\n$sp[9]\n\+\n$sp[10]\n";
	}
}

}

if ($gzip){
	close READONE_GZ;
	close READTWO_GZ;
} else {
	close READONE;
	close READTWO;
}
close SAM;

## remove temp files
if ($sort){
	unlink ($to_delete) unless ($keep);
}

## print stats
print "Processed ".commify($read_pairs_count)." pairs\n";
print STATS "Total pairs: ".commify($read_pairs_count)."\n";

my $rounded = sprintf("%.2f", ($read_pairs_exclude_exclude*100)/$read_pairs_count);
print STATS "Exclude | Exclude: ".commify($read_pairs_exclude_exclude)." ($rounded%)\n";

$rounded = sprintf("%.2f", ($read_pairs_exclude_unmapped*100)/$read_pairs_count);
print STATS "Exclude | Unmapped: ".commify($read_pairs_exclude_unmapped)." ($rounded%)\n";

$rounded = sprintf("%.2f", ($read_pairs_exclude_include*100)/$read_pairs_count);
print STATS "Exclude | Include: ".commify($read_pairs_exclude_include)." ($rounded%)\n";

$rounded = sprintf("%.2f", ($read_pairs_include_include*100)/$read_pairs_count);
print STATS "Include | Include: ".commify($read_pairs_include_include)." ($rounded%)\n";

$rounded = sprintf("%.2f", ($read_pairs_include_unmapped*100)/$read_pairs_count);
print STATS "Include | Unmapped: ".commify($read_pairs_include_unmapped)." ($rounded%)\n";

$rounded = sprintf("%.2f", ($read_pairs_unmapped_unmapped*100)/$read_pairs_count);
print STATS "Unmapped | Unmapped: ".commify($read_pairs_unmapped_unmapped)." ($rounded%)\n";

close STATS;


######################### sub-routines

sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    return scalar reverse $text;
}
