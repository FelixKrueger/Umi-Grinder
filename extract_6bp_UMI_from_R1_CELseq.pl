#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;

# This script is supposed to read Sharlene's celseq data, identify samples from base 7-12, assign the UMI (from bases 1-6) and then trim the sequences and map them somehow.

my $barcode_length = 6;
my %barcodes; # to be filled
my %r1_fhs;
my %r2_fhs;

my %celseq = (
    'AGACTC' => '1s',
    'AGCTTC' => '4s',
    'CATGAG' => '5s',
    'CAGATC' => '9s',
    'TCACAG' => '10s',
    'GTCTAG' => '23s',
    'GTTGCA' => '25s',
    'GTGACA' => '26s',
    'ACTCGA' => '31s',
    'TGCAGA' => '46s',
    );

while (@ARGV){
    my $file = shift @ARGV;
    my $pair_file = shift @ARGV;
    open_filehandles($file,$pair_file);
    split_barcodes($file,$pair_file);
    warn "done\n\n";
}
sub open_filehandles{
    my ($file,$pair_file) =  @_;
    for my $code (keys %celseq){
	my $out1 = $file;
	$out1 =~ s/R1/${code}_$celseq{$code}.R1/;
	# warn "new OUT1: $out1\n";
	open (my $fh," | gzip -c - > $out1") or die "Failed to open filehandle for $out1: $!\n";
	$r1_fhs{$code} = $fh;
	
	my $out2 = $pair_file;
	$out2 =~ s/R3/${code}_$celseq{$code}.R3/;
	# warn "new OUT2: $out2\n";
	open (my $fh2,"| gzip -c - > $out2") or die "Failed to open filehandle for $out2: $!\n";
	$r2_fhs{$code} = $fh2;
    }
}

sub split_barcodes {
    
    my ($file,$pair_file) =  @_;
    warn "Using files $file and $pair_file to search for UMIs\n";
    
    if ($file =~ /\.gz$/) {
	open (IN,"zcat $file |") or die $!;
    }
    else {
	open (IN,$file) or die $!;
    }
    if ($pair_file) {
	if ($file =~ /\.gz$/) {
	    open (IN2,"zcat $pair_file |") or die $!;
	}
	else {
	    open (IN2,$pair_file) or die $!;
	}
    }
    

    my $out1 = $file;
    die "renaming failed!\n" unless   ( $out1 =~ s/fastq\.gz$/UMI.fastq.gz/);
    # open (OUT,"| gzip -c - > $out1") or die $!;
    
    my $out2 = $pair_file;
    die "renaming failed!\n" unless   ( $out2 =~ s/fastq\.gz$/UMI.fastq.gz/);
    # open (OUT2,"| gzip -c - > $out2") or die $!;  
    
    my $gzip = 0;
    if ($file =~ /\.gz$/) {
	$gzip = 1;
    }
    
    my $count = 0; 
    
  SEQ:  while (my $id = <IN>) { # label
      my $seq = <IN>;
      my $id2 = <IN>;
      my $qual = <IN>;

      my $pair_id;
      my $pair_seq;
      my $pair_id2;
      my $pair_qual;
      
      $pair_id = <IN2>;
      $pair_seq = <IN2>;
      $pair_id2 = <IN2>;
      $pair_qual = <IN2>;
      ++$count;      
      # print "$seq\n$qual\n"; 
      my $umi = substr($seq,0,6);
      my $code = substr($seq,6,6);
      $seq = substr($seq,12);
      $qual = substr($qual,12);
      
      # print "$umi\n$code\n$seq\n$qual\n";      sleep(1);
      
      chomp $id;
      chomp $pair_id;
      $barcodes{$code}++;
      $id      .= ":code:$code:UMI:$umi\n";
      $pair_id .= ":code:$code:UMI:$umi\n";
      $id =~ tr/ /_/;
      $pair_id =~ tr/ /_/;
      
      #warn "$id"; sleep(1);
      if (exists $celseq{$code}){
	  print {$r1_fhs{$code}} $id;
	  print {$r1_fhs{$code}} $seq;
	  print {$r1_fhs{$code}} $id2;
	  print {$r1_fhs{$code}} $qual;
	  
	  print {$r2_fhs{$code}} $pair_id;
	  print {$r2_fhs{$code}} $pair_seq;
	  print {$r2_fhs{$code}} $pair_id2;
	  print {$r2_fhs{$code}} $pair_qual;
      }
      next SEQ;
  }
    warn "Processed $count lines in total\n";
    
    my $linecount = 0;
    warn "30 most frequent barcodes for files $file and $pair_file\n";
    foreach my $code (sort {$barcodes{$b}<=>$barcodes{$a}} keys %barcodes){
	++$linecount;
	warn "$code\t$barcodes{$code}\n";
	last if ($linecount == 30);
    }
    warn "\n\n";
    
    warn "Expected barcodes were:\n";
    foreach my $code (sort keys %celseq){
	my $perc = sprintf ("%.1f",$barcodes{$code}/$count *100);
	warn "$code\t$barcodes{$code} ($perc%)\n";
    }
    warn "\n\n";

}
