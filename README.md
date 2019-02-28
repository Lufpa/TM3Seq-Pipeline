# Snakemake workflow: Tn5 RNA-Seq Pipeline

Workflow for the Tn5-TagSeq manuscript

The workflow is written using [Snakemake](https://snakemake.readthedocs.io/).

Dependencies are installed using [Bioconda](https://bioconda.github.io/) where possible.

## Setup environment and run workflow

1.  Clone workflow into working directory

    ```
    git clone <repo> <dir>
    cd <dir>
    ```

2.  Input data

    Place demultiplexed fastq.gz files in `data` directory (see `RNAseq_demultiplex.sh` below)
    Edit `samples.tsv` to add samples

3.  Edit config as needed

    ```
    cp config.defaults.yml config.yml
    nano config.yaml
    ```

4.  Install dependencies into isolated environment

    ```
    conda env create -n <project> --file environment.yml
    ```

5.  Activate environment

    ```
    source activate <project>
    ```

6.  Execute workflow

    ```
    snakemake -n
    ```


## Running workflow on `gen-comp1`

```
snakemake --cluster-config cetus_cluster.yaml \
          --drmaa " --cpus-per-task={cluster.n} --mem={cluster.memory} --qos={cluster.qos}" \
          --use-conda -w 60 -rp -j 1000
```

## Testing

Tests cases are in the subfolder `.test`. They should be executed via continuous integration with Travis CI.


## Additional Scripts

 * `RNAseq_demultiplex.sh`

    Demultiplexes samples based on i7 barcodes. If several plates (different i5) were sequenced together, an initial demultiplex step has to be done using Lance's i5 code (i5_parse_gencomp1_template.sbatch)

    This step also generates the "listfiles" file used in the next scripts.

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
