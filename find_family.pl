#!/usr/bin/perl -w
use strict;

my %clust;
open my $out, ">", "gene_fams_cluster.txt";
print $out "Chromosome\tClusterID\tStart\tEnd\tCluster_Size\tGap_Size\tGenes\tCyclotides\tCycstein_Knot_Maize\tDefensins\tGlycosyltransferase\tMethyltransferase\tPKS\tReductases\tTerpene_Synthase\tp450\tTotal_Families\tTotal_Genes_in_Families\tPercentage_of_Cluster_in_Families\n";
my %genes;
my %families;
my @files = <../Gene_Families/*/*_fullength.fsa>;
for my $file (@files){
	$file =~ /..\/Gene_Families\/(.*?)\/.+_fullength.fsa/;
	my $fam = $1;
	print "$file\n";
	$families{$fam}=1;
	open my $tfile, "<", $file;
	while(<$tfile>){
		chomp;
		if(/>/){
			/>(Sobic\.\w+)\..+/;
			my $sname = $1;
			#if(/\.p/){
			#	/>(.+).p/;
			#	$sname = $1;
			#}
			$genes{$sname}=$fam;
		}
	}
}

open my $genes, "<", $ARGV[0];
while(<$genes>){
        chomp;
        my @tarray= split /\s+/;
	my @tgene= split(/,/, $tarray[6]);
	my %tfam;
	for my $fam (keys %families){
		$tfam{$fam}=0;
	}
	my $total=0;
	my $total_fam=0;
	for my $tgen (@tgene){
		if(exists $genes{$tgen}){
			$tfam{$genes{$tgen}}++;
			$total++;
		}
	}
	print $out "$_";
	
	for my $famname (sort {$a cmp $b} keys %tfam){
		print $out "\t$tfam{$famname}";
		if($tfam{$famname} > 0){
			$total_fam++;
		}
	}
	my $per_fam = $total/$tarray[4];
	print $out "\t$total_fam\t$total\t$per_fam";
	print $out "\n";
	
}
	
	
