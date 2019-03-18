# The main entry point of your workflow for Tn5 RNA-Seq Pipeline
# After configuring, running snakemake -n in a clone of this repository should
# successfully execute a dry-run of the workflow.

import pandas as pd
shell.executable("bash")

from snakemake.utils import min_version
min_version("5.2.0")

configfile: "config.defaults.yml"
#samples = pd.read_table(config["samples"], index_col="sample")
sample_files = snakemake.utils.listfiles(config["fastq_file_pattern"])
samples = dict((y[0], x) for x, y in sample_files)

log_dir = config["results_dir"] + "/logs"

def get_fastq(wildcards):
    return samples[wildcards.sample]


rule all:
    input:
        config["results_dir"] + "/multiqc.html",
        config["results_dir"] + "/combined_gene_counts.tsv"
        #expand("working/trimmed/{sample}.fastq.gz", sample=samples.keys())

include: "rules/fastqc.smk"
include: "rules/trim.smk"
include: "rules/align.smk"
include: "rules/dedup.smk"
include: "rules/count.smk"
include: "rules/summary.smk"
