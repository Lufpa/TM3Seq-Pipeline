# The main entry point of your workflow for Tn5 RNA-Seq Pipeline
# After configuring, running snakemake -n in a clone of this repository should
# successfully execute a dry-run of the workflow.

import pandas as pd
shell.executable("bash")

from snakemake.utils import min_version
min_version("5.2.0")

configfile: "config.defaults.yml"
sample_files = snakemake.utils.listfiles(config["fastq_file_pattern"]+"/{sample}.fastq.gz")
samples = dict((y[0], x) for x, y in sample_files)
assert len(samples) > 0, "ERROR: No fastq files were found using pattern '{}' (set in configfile)".format(config["fastq_file_pattern"])
SAMPLES_ALL = glob_wildcards(config['fastq_file_pattern']+"/{sample}.fastq.gz").sample
SAMPLES_PAIRED = glob_wildcards(config['fastq_file_pattern']+"/{sample}_R1_001.fastq.gz").sample

log_dir = config["results_dir"] + "/logs"

def get_fastq(wildcards):
    return samples[wildcards.sample]

if_SE=all("R2" not in name for name in samples.keys())

def get_matched_fastq(wildcards):   
    paired_files = [samples[i] for i in samples.keys() if ("R1" in i or "R2" in i) and wildcards.sample in i]
    print(wildcards)
    print(paired_files)
    if len(paired_files) == 2 :
        return paired_files
    else:
        raise ValueError(f"Error in matched pairs {wildcards.sample}")
        
def get_paired_fastq(wildcards):
    return get_matched_fastq(wildcards)



rule all:
    input:
        config["results_dir"] + "/multiqc.html",
        #config["results_dir"] + "/combined_gene_counts.tsv"
        #expand("working/trimmed/{sample}.fastq.gz", sample=samples.keys())

include: "rules/fastqc.smk"
include: "rules/trim.smk"
include: "rules/align.smk"
include: "rules/dedup.smk"
include: "rules/count.smk"
include: "rules/summary.smk"
