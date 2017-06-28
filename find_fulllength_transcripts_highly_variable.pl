#!/usr/bin/env perl -w
use strict;

my %subject;
my %query;

open my $qfile, "<", $ARGV[0];
my $qid;
while(<$qfile>){
	chomp;
	if(/^>/){
		$qid = substr($_,1);
	}
	else{
		$query{$qid}.=$_;
	}
}

open my $sfile, "<", $ARGV[1];
my $sid;
while(<$sfile>){
	chomp;
	if(/^>/){
		$sid = substr($_,1);
		if(exists $subject{$sid}){
			$sid = ();
		}
	}
	elsif($sid){
		$subject{$sid}.=$_;
	}
}

open my $out, ">", $ARGV[0] . "_fullength.fsa";

my %fullseqs;
open my $bfile, "<", $ARGV[2];
my $bid;
while(<$bfile>){
	chomp;
	my @tarray=split/\t/;
	#$tarray[1] =~ s/.p$/.t/g;
	#$tarray[1] =~ s/_P(\d+)$/_T$1/g;
	if(length($subject{$tarray[1]}) > 50){
		my $qhit = $tarray[7]-$tarray[6];
		my $shit = $tarray[9]-$tarray[8];
		
		my $qover = length($query{$tarray[0]});
		my $sover = length($subject{$tarray[1]});
		if(exists $fullseqs{$tarray[1]}){
			for (my $i=$tarray[8]-1; $i <= ($tarray[9]-1); $i++){
				@{$fullseqs{$tarray[1]}}[$i]++;
			}
		}
		else{
			for (my $j=0; $j<$sover; $j++){
				@{$fullseqs{$tarray[1]}}[$j]=0;
			}
			for (my $i=$tarray[8]-1; $i <= ($tarray[9]-1); $i++){
                                @{$fullseqs{$tarray[1]}}[$i]++;
                        }
		}
		
	}
}

for my $seqid (keys %fullseqs){
	my $sover = length($subject{$seqid});
	my $hit_count;
	for my $count (@{$fullseqs{$seqid}}){
		if($count > 0){
			$hit_count++;
		}
	}
	
	if($hit_count/$sover >= 0.75){
		print $out ">$seqid\n$subject{$seqid}\n";
	}
}	
