#!/bin/bash
#SBATCH --mem=2000
#SBATCH --time=2:00:00 --qos=1day
#SBATCH --job-name=demultiplex
#SBATCH --cpus-per-task=5
#SBATCH --output="%j.out"
#SBATCH --error="%j.error"

#Requires: the 3 fastq from sequences, BarcodeDemultiplex file (first column id, second i7 sequence)

date
r1=*read_1*
echo "read1 read"
r2=*read_2*
echo "read2 read"
r3=*read_3*
echo "read3 read"

#allows one mismatch in the barcodes
~/bin/fastq-multx/fastq-multx -m 1 -B BarcodeDemultiplex $r2 $r1 -o n/a -o %.R1.fq.gz |& tee log.demultiplexing

rm unmatched.R1.fq.gz

for file in *R1.fq.gz
do
echo $file >> listfiles
done

echo "Demultiplexing done"
