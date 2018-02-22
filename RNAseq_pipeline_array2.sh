#!/bin/bash
#SBATCH --mem=20000
#SBATCH --time=5-00:00:00 --qos=1wk
#SBATCH --job-name=SSS_old
#SBATCH --cpus-per-task=5
#SBATCH --output="%A_%a.out"
#SBATCH --error="%A_%a.error"
#SBATCH --array=1-6


##Requires: 
# Demultiplexed files (*R1.fq.gz)
# Read 3 (i5)
# AdaptersTrim.fasta file

## if nudup is gonna be used, set $inputcount to 'dedup', otherwilse set it to ''
## it requires the script "map_readcounts.sh" located in ~/varios/scripts/map_readcounts.sh



set -e 

date
inputcount='dedup'

#refgenome=~/genomes/hsapiens/genome
#annotation=~/genomes/hsapiens/Homo_sapiens.GRCh38.86.chr.protcoding.gtf

refgenome=~/genomes/dmel_genome/dmel-all-chromosome-r6.14
annotation=~/genomes/dmel_genome/dmel-all-r6.14.gtf

r3=*Read_3_Index_Read_passed_filter.fastq*
echo "Read3 read"

##allows one mismatch in the barcodes - This is being run in a differnet script
#~/bin/fastq-multx/fastq-multx -m 1 -B BarcodeDemultiplex $r2 $r1 -o n/a -o %.R1.fq.gz >&2 

#echo "Demultiplexing done"


#for file in *R1.fq.gz
#do
#echo $file >> listfiles
#done

source ~/varios/scripts/RNAseq_map_readcounts2.sh ${r3} ${inputcount} ${refgenome} ${annotation}

#echo "Start merging the counts of all samples"

#for file in *genecount; do cut -f7 $file > tmp$file; cut -f1,2,5,6 $file > names; done 
#cut -f1 names > a; cut -f2 names | sed 's/;.*//g' > b; cut -f3 names | sed 's/;.*//g' > c ; cut -f4 names > d ; paste a b c d tmp*genecount | sed '1d' > readcountsallsamples.txt ; rm tmp*genecount; rm names
# rm a b c d  #keep these files, sometimes the readcoutnsallsamples.txt is not ok, for whatever reason. 
#echo "Done merging counts for all samples, see readcountallsamples.txt"

#echo "Getting read parameters total_reads, kept, dropped, mapped, useful_reads, assigned_genes"
#parses the .log from previous steps and generates a file with total reads, dropped during trimming, kept, mapped, and total of useful reads. The number of read that were successfully assigned to genes durng gene count is the last column.

#for file in *error ; do awk '{if (NR==1) print $0}' $file  >> ids.txt; done
#grep 'filename' *error | awk '{print $2}' > ids.txt

#grep 'Input Reads' *error | awk '{print $3"\t"$6"\t"$9}' | sed -e 's/(//g' -e 's/)//g' > tmp.trimmomatic

#grep 'of input' *error | awk '{print $4}' > tmp.mapping

#grep 'Total reads' *error | awk '{print $5}' > tmp.totalreadsgenecount   ##check that adding the log of nudup doesnt affect this grep###

#grep 'Successfully' *error | awk '{print $6}'  > tmp.assignedreadsgenecount

#paste ids.txt tmp.trimmomatic tmp.mapping tmp.totalreadsgenecount tmp.assignedreadsgenecount  > read.parameters.txt
#sed -i '1isample\ttotal_reads\tkept\tdropped\tmapped\tuseful_reads\tassigned_genes'  read.parameters.txt

#rm ids.txt tmp.trimmomatic tmp.mapping tmp.totalreadsgenecount tmp.assignedreadsgenecount listfiles 

#rm -r tmp*.gz

echo "Done!"
date
