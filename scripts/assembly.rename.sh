assemblyfile=$1
assemblyversion=$2
  
fastaqual_select.pl -f $assemblyfile -s L |
perl -lne '
  if (/^>(\S+)/) {
    printf (">'$assemblyversion'.scaf%05d\n",++$i);
    print STDERR "$1\t". sprintf ("'$assemblyversion'.scaf%05d",$i);
    next
  };
  print;
' >$assemblyversion.fna 2>$assemblyversion.map
