#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;

my $barcode_length = 8;

while (@ARGV){
    my $file = shift @ARGV;
    my $pair_file = shift @ARGV;

    split_barcodes($file,$pair_file);
    warn "done\n\n";
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
    open (OUT,"| gzip -c - > $out1") or die $!;

    my $out2 = $pair_file;
    die "renaming failed!\n" unless   ( $out2 =~ s/fastq\.gz$/UMI.fastq.gz/);
    open (OUT2,"| gzip -c - > $out2") or die $!;  
    
    my $gzip = 0;
    if ($file =~ /\.gz$/) {
	$gzip = 1;
    }
    
    
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
      
      my $umi = substr($pair_seq,0,8);

      $pair_seq = substr($pair_seq,8);
      $pair_qual = substr($pair_qual,8);
      
      # print "$umi\n$pair_seq\n$pair_qual\n$seq\n$qual\n";      sleep(1);

      chomp $id;
      chomp $pair_id;

      $id .= ":$umi\n";
      $pair_id .= ":$umi\n";
      #	warn "$id";
      print OUT $id;
      print OUT $seq;
      print OUT $id2;
      print OUT $qual;
      
      print OUT2 $pair_id;
      print OUT2 $pair_seq;
      print OUT2 $pair_id2;
      print OUT2 $pair_qual;

      next SEQ;
  }
}
