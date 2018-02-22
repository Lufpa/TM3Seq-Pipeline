#/bin/bash

#Batch parameters are specified in test...sh script that calls this script

r3=$1
inputcount=$2
refgenome=$3
annotation=$4


fqfile=`awk -v file=$SLURM_ARRAY_TASK_ID '{if (NR==file) print $0 }' listfiles`
echo "filename " $fqfile >&2

#echo "Start trimming"
trimfile=`basename ${fqfile%R*}trim.fq.gz`
java -jar ~/bin/Trimmomatic-0.32/trimmomatic-0.32.jar SE -threads 5 $fqfile $trimfile ILLUMINACLIP:AdaptersTrim.fasta:1:30:7 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:20

echo "Done with trimming"
mapfile=${trimfile%trim*}map.bam
summaryfile=${trimfile%trim*}summarymap.txt
tmpdir=tmp$trimfile
mkdir $tmpdir
echo "Starting mapping"
~/bin/tophat-2.1.1.Linux_x86_64/tophat2 -o $tmpdir $refgenome $trimfile
mv $tmpdir/accepted_hits.bam $mapfile
mv $tmpdir/align_summary.txt $summaryfile
echo "Done mapping"

grep 'of input' $summaryfile >&2

echo "Start dropping multiple mapping reads"
#filters out multiple mapping reads
uniqfile=${mapfile%map.bam}uniq.bam
samtools view -b -q 50 $mapfile -o $uniqfile
echo "Done dropping multiple mapping reads"


### if working with TagSeq data, read 3 will be read at the beggining of this script and nudup deduplication will start, otherwise it will not find read 3 and will skip this step writing an error msg in the .error file. 

echo "Start pcr deduplication - nudup"
# nudup removes (can be just marked if wanted) pcr duplicates useing the UMI from i5 and start pos. It takes for ever to run, couple of hours per sample. If preliminary results wanted, skip this step.

dedupfile=${uniqfile%.bam}
python ~/bin/nudup/nudup.py -f $r3 -o $dedupfile -s 8 -l 8 --rmdup-only $uniqfile >&2
echo "Done pcr dedup for" $uniqfile

echo "Start gene count using dedupfile" $dedupfile

countfile=${dedupfile}.genecount

#echo "Skipping nudup, Start gene count using uniqfile" $uniqfile

if [ $inputcount == 'dedup' ]
then
	~/bin/subread-1.5.1-Linux-x86_64/bin/featureCounts -T 5 -t exon -g gene_id -a $annotation -o $countfile ${dedupfile}.sorted.dedup.bam
	echo "Done gene count for deduplicated file" $dedupfile
else
	 ~/bin/subread-1.5.1-Linux-x86_64/bin/featureCounts -T 5 -t exon -g gene_id -a $annotation -o $countfile $uniqfile
	echo "Done gene count for non-deduplicated file" $uniqfile
fi



