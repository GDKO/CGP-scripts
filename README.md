# CGP-scripts

Scripts for the Caenorhabditis genome project

### kmer_histo.R
Creates an R histogram plot from the kmc_tools histogram output
```
kmer_histo.R histo.txt
```
### clc_len_cov_gc_insert.pl
Outputs the insert size of the reads
```
clc_len_cov_gc_insert.pl \
-c [lib.cas] \   # The cas file
-i \             # Output the insert sizes
-o [lib] \       # Output prefix
-lib [lib]       # Lib name
```
### plot_insert_freq_txt_binned.R
Creates an R histogram plot from clc_len_cov_gc_insert.pl output
```
Requires ggplot2

plot_insert_freq_txt_binned.R [lib.cas.insert.freq.txt]
```
