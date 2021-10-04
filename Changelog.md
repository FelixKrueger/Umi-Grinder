# UmiBam Changelog

### Version 0.2.0dev

- Added Hi-C functionality using the option `--hic`. This expects data in the format output by HiCUP, so a paired-end data format, where read-pairs follow each other on consecutive lines. Deduplication occurs on mapping combinations where read pais can be mapped as either R1/R2 or R2/R1. All modes of deduplication work, i.e. just positional, UMI (no mismatches), or UMI with mismatches.

- Added a detailed UMI report for Hi-C mode, using the option `--detail`. This outputs a file in the following format:
```
UMI	count	R1 chrom	R1 pos	R2 chrom	R2 pos
TAAAGCGATCT	116	chr17	65539294	chr17	65540317
```

- Changed auto-detection to identify single-/paired-end for Bowtie2, HISAT2 or Bismark, and just once per @PG line.

### Version 0.2.0 

- Added handling of softclipped reads (CIGAR operation: S)
