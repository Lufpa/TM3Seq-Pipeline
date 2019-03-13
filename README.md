# Snakemake workflow: Tn5 RNA-Seq Pipeline

Workflow for the Tn5-TagSeq manuscript.

The workflow is written using [Snakemake](https://snakemake.readthedocs.io/).
Dependencies are installed using [Bioconda](https://bioconda.github.io/).


## Overview

This workflow is designed to generate counts of the number of uniquly mapped reads to each gene for each sample provided.

### Inputs

*   Fastq files for each sample
*   Reference sequence in FASTA format
*   Gene model in GTF format
*   Configuration file(s) in YAML format

### Outputs

*   `combined_gene_counts.tsv` - Tab delimited file of gene counts, one row per gene and one column per sample
*   `multiqc.html` - Quality control summary showing number of reads, trimming, mapping, and counting statistics
*   `logs\` - Directory of log files for each job
*   `working\` - Directory containing intermediate files for each job (*e.g.* bam files and count files for each sample)

### Workflow

1.  **Fastq summary and QC metrics** - Use [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) to determine some basic QC metrics from the raw fastq files
2.  **Trim reads** - Use [Trimmomatic](http://www.usadellab.org/cms/?page=trimmomatic) to trim off adapter and low quality sequence from the ends of reads
3.  **Align reads** - Use [STAR](https://github.com/alexdobin/STAR) to aign reads to the genome, accounting for known splice junctions
4.  **Deduplicate (optional)** - Remove duplicates using [nudup](https://github.com/nugentechnologies/nudup) which utilizes unique molecular identifiers
5.  **Count** - Use [featureCounts](http://bioinf.wehi.edu.au/featureCounts/) (part of the [Subread package](http://subread.sourceforge.net/)) to quanify the number of reads uniquly mapped to each gene
6.  **Summarize** - Combine the count files and run [MultiQC](https://multiqc.info/) to generate a summary report


## Setup environment and run workflow

1.  Clone workflow into working directory

    ```bash
    git clone <repo> <dir>
    cd <dir>
    ```

2.  Input data

    Place demultiplexed `fastq.gz` files in a `data` directory (see `RNAseq_demultiplex.sh` below)

3.  Edit configuration files as needed

    ```bash
    cp config.defaults.yml myconfig.yml
    nano myconfig.yaml
    
    # Only if running on a cluster
    cp cluster_config.yml mycluster_config.yml
    nano mycluster_config.yml
    ```

4.  Install dependencies into an isolated environment

    ```bash
    conda env create -n <project> --file environment.yml
    ```

5.  Activate the environment

    ```bash
    source activate <project>
    ```

6.  Execute the workflow

    ```bash
    snakemake --configfile "myconfig.yml" --use-conda 
    ```

## Common options

*   `--configfile "myconfig.yml"` - Override defaults using the configuration found in `myconfig.yml`
*   `--use-conda` - Use [conda]() to create an environment for each rule, installing and using the exact version of the software required (recommended)
*   `--cores` - Use at most N cores in parallel (default: 1). If N is omitted, the limit is set to the number of available cores.
*   `--cluster` - Execute snakemake rules with the given submit command, *e.g.* `qsub`. Snakemake compiles jobs into scripts that are submitted to the cluster with the given command, once all input files for a particular job are present. The submit command can be decorated to make it aware of certain job properties (input, output, params, wildcards, log, threads and dependencies (see the argument below)), *e.g.*: `$ snakemake –cluster ‘qsub -pe threaded {threads}’`.
*   `--drmaa` - Execute snakemake on a cluster accessed via [DRMAA](https://en.wikipedia.org/wiki/DRMAA). Snakemake compiles jobs into scripts that are submitted to the cluster with the given command, once all input files for a particular job are present. `ARGS` can be used to specify options of the underlying cluster system, thereby using the job properties input, output, params, wildcards, log, threads and dependencies, *e.g.*: `--drmaa ‘ -pe threaded {threads}’`. Note that `ARGS` must be given in quotes and with a leading whitespace.
*   `--cluster-config` - A JSON or YAML file that defines the wildcards used in `cluster` for specific rules, instead of having them specified in the Snakefile. For example, for rule `job` you may define: `{ ‘job’ : { ‘time’ : ‘24:00:00’ } }` to specify the time for rule `job`. You can specify more than one file. The configuration files are merged with later values overriding earlier ones.
*   `--dryrun` - Do not execute anything, and display what would be done. If you have a very large workflow, use `--dryrun --quiet` to just print a summary of the DAG of jobs.

See the [Snakemake documentation for a list of all options](https://snakemake.readthedocs.io/en/stable/executable.html#all-options).


## Examples 

### Running workflow on a single computer with 4 threads

```bash
snakemake --configfile "myconfig.yml" --use-conda --cores 4
``` 

### Running workflow using SLURM

```bash
snakemake \
    --configfile "myconfig.yml" \
    --cluster-config "mycluster_config.yml" \
    --cluster "sbatch --cpus-per-task={cluster.n} --mem={cluster.memory} --time={cluster.time}" \
    --use-conda \
    --cores 100
``` 

### Running workflow on Princeton LSI cluster using [DRMAA](https://en.wikipedia.org/wiki/DRMAA)

```bash
snakemake \
    --configfile "myconfig.yml" \
    --cluster-config "cetus_cluster.yaml" \
    --drmaa " --cpus-per-task={cluster.n} --mem={cluster.memory} --qos={cluster.qos} --time={cluster.time}" \
    --use-conda \
    --cores 1000 \
    --output-wait 60
```


## Additional Scripts

*   `RNAseq_demultiplex.sh`

    Demultiplexes samples based on i7 barcodes. If several plates (different i5) were sequenced together, an initial demultiplex step has to be done using Lance's i5 code (i5_parse_gencomp1_template.sbatch)
