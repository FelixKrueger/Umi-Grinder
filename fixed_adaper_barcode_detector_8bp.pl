#!/usr/bin/perl
use warnings;
use strict;

my @in1 = glob ('lane[34]*R1.fastq.gz');
my @in2 = glob ('lane[34]*R2.fastq.gz');
my %freqs;

while (@in1){
    my $in1 = shift @in1;
    my $in2 = shift @in2;
    open (IN1,"zcat $in1 |") or die $!;
    open (IN2,"zcat $in2 |") or die $!;

    %freqs = ();

    die "The input iles do not end in .fastq.gz. Please respecify!\n" unless ($in1 =~ /fastq\.gz$/ and $in2 =~ /fastq\.gz$/);
    my $out1 = $in1;
    die "Failed to rename $out1\n" unless ($out1 =~ s/fastq\.gz$/barcode_removed.fastq.gz/);
    my $out2 = $in2;
    die "Failed to rename $out2\n" unless ($out2 =~ s/fastq\.gz$/barcode_removed.fastq.gz/);
    
    open (OUT1,"| gzip -c - > $out1") or die $!;
    open (OUT2,"| gzip -c - > $out2") or die $!;
    
    print "Processing files $in1 and $in2\n";
    my %r1; # storing the barcodes for R1
    my %r2; # storing the barcodes for R2
    
    my %fix1; # storing the fixed sequence (CAGT + A from A-tailing) of R1
    my %fix2; # storing the fixed sequence (CAGT + A from A-tailing) of R2
    
    my $count = 0;
    my $filtered_count = 0;
    my $r1_contains_rc = 0;
    
    
    while (1){
	
	my $one1 = <IN1>;
	my $one2 = <IN1>;
	my $one3 = <IN1>;
	my $one4 = <IN1>;
	
	my $two1 = <IN2>;
	my $two2 = <IN2>;
	my $two3 = <IN2>;
	my $two4 = <IN2>;
	
	last unless  ($one4 and $two4);
	chomp $one2;
	chomp $two2;
	
	chomp $one1; # need to append barcode to the read ID
	chomp $two1;
	
	chomp $one4; # need to be shortened too
	chomp $two4; 
	
	++$count; # line count
	
	my $r1_barcode;
	my $r2_barcode;
	my $r1_fix;
	my $r2_fix;
	
	
	$r1_barcode = substr($one2,0,8);
	$r2_barcode = substr($two2,0,8);
	$r1_fix = substr($one2,8,4);
	$r2_fix = substr($two2,8,4);
	# warn "$one2\n$two2\n$r1_barcode\t$r1_fix\n$r2_barcode\t$r2_fix\n\n";sleep(1);
	unless ($r1_fix eq 'CAGT' and $r2_fix eq 'CAGT'){
	    $freqs{$r1_fix}++;
	    $freqs{$r2_fix}++;
	    # next;
	}
	$filtered_count++;

	#### Capturing the sequence after the A from A-tailing
	my $seq1 = substr($one2,13); # truncated sequence without barcode or fixed sequence
	my $seq2 = substr($two2,13);

	my $qual1 = substr($one4,13); # truncated quality string without barcode or fixed sequence
	my $qual2 = substr($two4,13);

	# warn "$one1\n";
	$one1 .= ":R1:${r1_barcode}:R2:${r2_barcode}:F1:${r1_fix}:F2:${r2_fix}";
	#warn "$one1\n";

	#warn "$two1\n";
	$two1 .= ":R1:${r1_barcode}:R2:${r2_barcode}:F1:${r1_fix}:F2:${r2_fix}";
	#warn "$two1\n";
	#   warn "$one2\n          $seq1\n$one4\n          $qual1\n~~\n$two2\n          $seq2\n$two4\n          $qual2\n\n";sleep(1);

	print OUT1 "$one1\n";
	print OUT1 "$seq1\n";
	print OUT1 "$one3";
	print OUT1 "$qual1\n"; 

	print OUT2 "$two1\n";
	print OUT2 "$seq2\n";
	print OUT2 "$two3";
	print OUT2 "$qual2\n"; 

       # sleep(1);

	$r1{$r1_barcode}++;
	$r2{$r2_barcode}++;

	$fix1{$r1_fix}++;
	$fix2{$r2_fix}++;

	### Now looking for the R2 barcode and fixed sequence in R1
	my $compound = $r2_barcode.$r2_fix; # start of R2, should also be found as reverse complement in R1
	my $rc = rc($compound); # string to look for in R1
	#  warn "$two2\n          $seq2\n$compound\n$rc\n"; sleep(1);

	next unless ($seq1 =~ /$rc/);
	$r1_contains_rc++;

    }


    my $perc;
    my $perc_contains_r2;

    if ($count){   
	$perc = sprintf("%.2f",$filtered_count/$count * 100);
	$perc_contains_r2 = sprintf("%.2f",$r1_contains_rc/$count * 100);
    }
    else{
	$perc = 'N/A';
	$perc_contains_r2 = 'N/A';
    }
    
    warn "Sequences processed in total: $count\nthereof had fixed sequence CAGT in both R1 and R2:\t $filtered_count ($perc%)\n"; 
    warn "R1 contained barcode and fixed sequence of R2 (as reverse complement):\t$r1_contains_rc ($perc_contains_r2%)\n\n";


    my $lines = 0;
    print "Barcode frequencies for Read 1:\n\nBarcode\tCount\n=============\n";

    foreach my $barcode(sort {$r1{$b}<=>$r1{$a}} keys %r1){
	++$lines;
	last if ($lines == 50);
	print "$barcode\t$r1{$barcode}\n";
    }

    print "\n";

    $lines = 0;
    print "Barcode frequencies for Read 2:\n\nBarcode\tCount\n=============\n";
    foreach my $barcode(sort {$r2{$b}<=>$r2{$a}} keys %r2){
	++$lines;
	last if ($lines == 50);
	print "$barcode\t$r2{$barcode}\n";
    }
    print "\n";

    $lines = 0;
    print "Fixed sequence frequencies for Read 1:\n\nFixed\tCount\n=============\n";
    foreach my $barcode(sort {$fix1{$b}<=>$fix1{$a}} keys %fix1){
	++$lines;
	last if ($lines == 50);
	print "$barcode\t$fix1{$barcode}\n";
    }
    print "\n";

    $lines = 0;
    print "Fixed sequence frequencies for Read 2:\n\nFixed\tCount\n=============\n";
    foreach my $barcode(sort {$fix2{$b}<=>$fix2{$a}} keys %fix2){
	++$lines;
	last if ($lines == 50);
	print "$barcode\t$fix2{$barcode}\n";
    }

    print "\n";
    print "Fixed sequence of removed sequences was:\n";
    foreach my $seq (sort {$freqs{$b}<=>$freqs{$a}} keys %freqs){
	print "$seq\t$freqs{$seq}\n";
    }

}



################### SUBROUTINES


sub rc{
    my $string = shift;
    $string = reverse($string);
    $string =~ tr/GATC/CTAG/;
    return $string;
}



