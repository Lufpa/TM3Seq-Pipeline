def get_fastq(wildcards):
    return samples[wildcards.sample]


rule trimmomatic:
    input:
        get_fastq
    output:
        fastq="working/trimmed/{sample}.fastq.gz",
    params:
        trimmer=config["params"]["trimmomatic"]["trimmers"],
        extra=config["params"]["trimmomatic"]["extra"]
    log:
        "logs/trimmomatic/{sample}.log"
    wrapper:
        "0.23.1/bio/trimmomatic/se"
