# CGP-scripts

Scripts for the Caenorhabditis genome project

### kmer_histo.R
Creates an R histogram plot from the kmc_tools histogram output
```
kmer_histo.R histo.txt
```
### clc_insert.pl
Outputs the insert size of the reads
```
clc_insert.pl \
-c [lib.cas] \   # The cas file
-i \             # Output the insert sizes
-o [lib] \       # Output prefix
-lib [lib]       # Lib name
```
### plot_insert_freq_txt_binned.R
Creates an R histogram plot from clc_insert.pl output
```
Requires ggplot2

plot_insert_freq_txt_binned.R [lib.cas.insert.freq.txt]
```
### daa_to_tagc.pl
Creates a tagc readable format from dianmond's daa
```
Required diamond in the path

daa_to_tagc.pl uniref100.taxlist [assembly_se_uniref.daa]
```
