#!/usr/bin/perl -w
use strict;

my %gff;

open my $file, "<", $ARGV[0];
while(<$file>){
	chomp;
	if(/^\#\#/){
		next;
	}
	else{
		my @tarray = split /\s+/;
		if($tarray[2] eq "gene"){
			$tarray[8] =~ /Name\=(.*?)$/;
			$gff{$tarray[0]}{$tarray[3]}{$tarray[4]}=$1;
		}
		
	}
}


my %genes;

open my $file2, "<", $ARGV[1];
while(<$file2>){
		chomp;
		if(/^>/){
				my $genename = substr($_, 1);
				$genes{$genename}=$1;
		}
}

my %used;
my %clusters;
my $tempstart;
my $tempend;
my $previous_gene;
my $missed_count=0;
my $cluster_count=0;
my $max_missed=0;
for my $chrom (sort keys %gff){
	
	for my $start (sort {$a<=>$b} keys %{$gff{$chrom}}){
		for my $end (keys %{$gff{$chrom}{$start}}){
			if($previous_gene){
				if(exists $genes{$gff{$chrom}{$start}{$end}}){
					$missed_count=0;
					$tempend = $end;
					$tempstart = $start;
					%used=();
					$previous_gene = $gff{$chrom}{$start}{$end};
					my $clustername = "cluster" . $cluster_count;
					$clusters{$chrom}{$clustername}{END}=$end;
					$clusters{$chrom}{$clustername}{GENES}{$gff{$chrom}{$start}{$end}}=1;

				}
				else{
					if($missed_count > $max_missed){
						$max_missed = $missed_count;
					}
					$missed_count++;
					$used{$gff{$chrom}{$start}{$end}}=1;
					if($missed_count > $ARGV[2]){
						my $clustername = "cluster" . $cluster_count;
						$missed_count = 0;
						$previous_gene = ();
						$tempstart = ();
						$tempend = ();
						my $index_count=0;
						for my $gene (keys %{$clusters{$chrom}{$clustername}{GENES}}){
								if(exists $used{$gene}){
									delete $clusters{$chrom}{$clustername}{GENES}{$gene};
								}
						}
						$cluster_count++;

					}
					else{
						$tempend = $end;
						$tempstart = $start;
						$previous_gene = $gff{$chrom}{$start}{$end};
						my $clustername = "cluster" . $cluster_count;
						$clusters{$chrom}{$clustername}{END}=$end;
						$clusters{$chrom}{$clustername}{GENES}{$gff{$chrom}{$start}{$end}}=1;
						$clusters{$chrom}{$clustername}{MAXMISSED}=$max_missed;
					}
				}

			}
			else{
				if(exists $genes{$gff{$chrom}{$start}{$end}}){
					$missed_count=0;
					$max_missed=0;
					$tempend = $end;
					$tempstart = $start;
					$previous_gene = $gff{$chrom}{$start}{$end};
					my $clustername = "cluster" . $cluster_count;
					$clusters{$chrom}{$clustername}{START}=$start;
					$clusters{$chrom}{$clustername}{END}=$end;
					$clusters{$chrom}{$clustername}{GENES}{$gff{$chrom}{$start}{$end}}=1;

				}
			}
		}
	}
}

open my $out, ">", "Identified_Clusters.txt";
for my $chr (sort keys %clusters){
		for my $clnames (keys %{$clusters{$chr}}){
			if (keys %{$clusters{$chr}{$clnames}{GENES}} >= 2){
				my $clustersize = keys %{$clusters{$chr}{$clnames}{GENES}};
				print $out "$chr\t$clnames\t$clusters{$chr}{$clnames}{START}\t$clusters{$chr}{$clnames}{END}\t$clustersize\t$clusters{$chr}{$clnames}{MAXMISSED}\t";
				for my $genename (keys %{$clusters{$chr}{$clnames}{GENES}}){
					print $out "$genename,";
				}
				print $out "\n";
			}
		}
}
