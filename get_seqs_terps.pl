#!/usr/bin/perl -w
use strict;

my %genes;
open my $file, "<", $ARGV[0];
while(<$file>){
	chomp;
	$genes{$_}=1;
}

open my $out, ">", $ARGV[0] . "_seqs.fsa";

open my $file2, "<", $ARGV[1];
my $temp;
while(<$file2>){
	chomp;
	if(/>/){
		$temp=();
		for my $gene (keys %genes){
			if($_ =~ /$gene/){
				$temp = $_;
				print $out "$_\n";
			}
		}
	}
	elsif($temp){
		print $out "$_\n";
	}
}
