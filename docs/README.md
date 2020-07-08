# UmiBam: Full list of options

### USAGE: UmiBam [options] filename(s)

`-s/--single`

deduplicate single-end BAM files

`-p/--paired`

deduplicate paired-end BAM files

`--umi`

In addition to chromosome, start position and orientation this will also take a potential UMI into consideration while deduplicating. The barcode needs to be the last element of the read ID and separated by a ':', e.g.: `MISEQ:14:000000000-A55D0:1:1101:18024:2858_1:N:0:CTCCT`

`--double_umi`

If the file was double-barcoded this mode extracts both Read 1 and Read 2 barcodes for the UMI deduplication. In its current implementation the two UMIs are expected to the in a format like this: `HWI-D00436:267:C71A4ANXX:5:1102:1531:82511_1:N:0:_TCTCACGG:R1:CCAACCTA:R2:TATGGGGT:F1:CAGT:F2:CAGT`. The barcodes following R1: and R2: are being used, here `CCAACCTA` and `TATGGGGT`.

`--mm/--mismatches <INT>`

Number of mismatches tolerated in the UMI. If a sequence has the same edit (hemming) distance to several different UMIs the read will be regarded as a duplicate and discarded. Currently allowed maximum of `--mm` is 6. Default: 0.

`--bam`

The output will be written out in BAM format instead of the default SAM format. This script will attempt to use the path to Samtools that was specified with '--samtools_path', or, if it hasn't been specified, attempt to find Samtools in the PATH. If no installation of Samtools can be found, the SAM output will be compressed with GZIP instead (yielding a .sam.gz output file)

`--samtools_path`

The path to your Samtools installation, e.g. /home/user/samtools/. Does not need to be specified explicitly if Samtools is in the `PATH` already

`--version`

Print version information and exit

`--help`

Print this help and exit
