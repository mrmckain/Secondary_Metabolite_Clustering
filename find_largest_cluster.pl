#!/usr/bin/perl -w
use strict;

my $cluster;
my $size=0;

open my $file, "<", $ARGV[0];
while(<$file>){
	chomp;
	my @tarray = split /\s+/;
	my @size = split(/,/,$tarray[4]);
	my $tsize = @size;
	if($tsize > $size){
		$size = $tsize;
		$cluster = $_;
	}
}

print "$cluster\n";
