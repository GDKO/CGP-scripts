#!/usr/bin/env Rscript
# Author: Georgios Koutsovoulos


library(tools)
args <- commandArgs(trailingOnly = TRUE)
file <- args[1]
kmer19PE <- read.table(file,header=F)
pdf(paste(file_path_sans_ext(file),".pdf",sep=""))
maxofy <- pretty (max(subset (kmer19PE, V1>10)$V2))[2]
barplot(kmer19PE[,2], xlim=c(0,300), ylim=c(0,maxofy), ylab="No of kmers", xlab="k-mer frequency class", names.arg=kmer19PE[,1], cex.names=0.8)
dev.off()
