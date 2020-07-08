# UmiBam
As Unique Molecule Identifiers (UMIs) become more and more frequently used for sequencing applications we need to take them into consideration when deduplicating data that aligns to the same positions in the genome.

UmiBam is supposed to remove alignments to the same position in the genome from both single-end and paired-end BAM files, which can arise e.g. by excessive PCR amplification. If sequences align to the same genomic position but on different strands they will be scored individually.

UmiBam keeps the first alignment to a given position and discards all others (as alignments are not ordered in any way this is also near enough random).

**Deduplication of single-end alignments uses:**

chromosome:start coordinate:strand:[UMI]

**Deduplication of paired-end alignments uses:**

chromosome:start coordinate:end coordinate:strand:[UMI]

The default deduplication mode will just work on positions, but it can also use UMIs in addition to the alignment position (please see options `--umi` and `--double_umi`). In UMI mode, UMIs will be used as exact matches in it's default mode. Alternatively, 1 or 2 mismatches can be allowed using the option `--mm`, but just as a word of warning: this increases the compute time hugely (and often doesn't affect the results whatsoever...).

UmiBam accepts BAM files with `CIGAR` operations `M` (match), `D` (deletion), `I` (insertion), `N` (splice-junction) and `S` (soft-clipping).

