# The main entry point of your workflow for Tn5 RNA-Seq Pipeline
# After configuring, running snakemake -n in a clone of this repository should
# successfully execute a dry-run of the workflow.

import pandas as pd
shell.executable("bash")


configfile: "config.yaml"
#samples = pd.read_table(config["samples"], index_col="sample")
sample_files = snakemake.utils.listfiles(config["fastq_file_pattern"])
samples = dict((y[0], x) for x, y in sample_files)


def get_fastq(wildcards):
    return samples[wildcards.sample]


rule all:
    input:
        config["results_dir"] + "/multiqc.html"
        # Subsequent target rules can be specified below. They should start with all_*.

include: "rules/fastqc.smk"
include: "rules/trim.smk"
include: "rules/align.smk"
include: "rules/count.smk"
include: "rules/summary.smk"
