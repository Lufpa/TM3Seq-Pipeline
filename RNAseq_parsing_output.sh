#!/bin/bash
#SBATCH --mem=2000
#SBATCH --time=1:00:00 --qos=1day
#SBATCH --job-name=pars_rna
#SBATCH --cpus-per-task=1
#SBATCH --output="%j.out"
#SBATCH --error="%j.error"

#this code makes the readcountallsamples.txt file, that will be used for gene expression analyses
#also, makes the read.parameters file. Summarizes total reads, mapped, trimmed, etc
# it might deserve a bit of work to get to a file with percentages , add a R script or so at the end

echo "Start merging the counts of all samples"

for file in *genecount; do cut -f7 $file > tmp$file; cut -f1,2,5,6 $file > names; done
cut -f1 names > a; cut -f2 names | sed 's/;.*//g' > b; cut -f3 names | sed 's/;.*//g' > c ; cut -f4 names > d ; paste a b c d tmp*genecount | sed '1d' > readcountsallsamples.txt ; rm tmp*genecount; rm names
 rm a b c d  #keep these files, sometimes the readcoutnsallsamples.txt is not ok, for whatever reason.
echo "Done merging counts for all samples, see readcountallsamples.txt"

echo "Getting read parameters total_reads, kept, dropped, mapped, useful_reads, assigned_genes"
#parses the .log from previous steps and generates a file with total reads, dropped during trimming, kept, mapped, and total of useful reads. The number of read that were successfully assigned to genes durng gene count is the last column.

#for file in *error ; do awk '{if (NR==1) print $0}' $file  >> ids.txt; done
for file in *_*error; do echo $file >> errorid; done

grep 'filename' *_*error | awk '{print $2}' > ids.txt

grep 'Input Reads' *_*error | awk '{print $3"\t"$6"\t"$9}' | sed -e 's/(//g' -e 's/)//g' > tmp.trimmomatic

grep 'of input' *_*error | awk '{print $4}' > tmp.mapping

grep 'Total reads' *_*error | awk '{print $5}' > tmp.totalreadsgenecount   ##check that adding the log of nudup doesnt affect this grep###

grep 'Successfully' *_*error | awk '{print $6}'  > tmp.assignedreadsgenecount

paste errorid ids.txt tmp.trimmomatic tmp.mapping tmp.totalreadsgenecount tmp.assignedreadsgenecount  > read.parameters.txt
sed -i '1iid\tsample\ttotal_reads\tkept\tdropped\tmapped\tuseful_reads\tassigned_genes'  read.parameters.txt

#rm errorid ids.txt tmp.trimmomatic tmp.mapping tmp.totalreadsgenecount tmp.assignedreadsgenecount listfiles
rm -r tmp*.gz

echo "Done!"
date
