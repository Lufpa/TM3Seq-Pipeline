# RNAseq_pipeline
Scripts for the Tn5-TagSeq manuscript


1. *demultiplex.sh 
Demultiplexes samples based on i7 barcodes. If several plates (different i5) were sequenced together, an initial demultiplex step has to be done using Lance's i5 code (i5_parse_gencomp1_template.sbatch)

This step also generales the "listfiles" file used in the next scripts.

2. *pipeline_array2.sh
This script runs all samples in an array by calling *map_readcoutns2.sh" that is where the trimming, mapping, deduplication (UMIs), and genecount happens. 
It defines whether deduplication should be done or not, and defines the genome and genome annotation variabiles. 

3. *parsing_output.sh
This scripts outputs 2 files
- readcountsallsamples.txt, it contains the read counts per gene per samples for all the samples processed in the array
- read.parameters, it contains the number of raw reads, trimmed out, mapped, assigned to genes, etc. 


--> to do
a)  Merge these scripts into one single script that runs non stop. I prefer to have them separate from each other, and double check that raw reads from the demultiplexing look fine before going into the actual processing of the data. But i guess, it looks nicer if we provide a script that runs from beginning to end.  
Script 3 is separated from 2 (the script that does all the analyses) because otherwise it is re-run in every array job messing up the final parsing of the data. I'm sure you'll know how to incorporate it into the script 2. 

b) I'll be cool to generate some simple plots. I have in mind:
- Adding a line of R in the parsing of the output script, and plot the read.parameters file. 
- We can make the readcountsallsamples.txt into a ready to read DESeq2 file. I format it by hand, because I usually clean up some samples that don't contain as munch info as I want.


--> We can talk later on about what other things we might want to add. 
But in general, what we want from this is a GitHub page with the scripts leading to a genecounts file that people can use in downstream analyses. 

