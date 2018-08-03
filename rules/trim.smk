rule trimmomatic:
    input:
        get_fastq
    output:
        fastq=config["working_dir"] + "/trimmed/{sample}.fastq.gz"
    params:
        trimmer=config["params"]["trimmomatic"]["trimmers"],
        extra=config["params"]["trimmomatic"]["extra"]
    log:
        log_dir + "/trimmomatic/{sample}.log"
    wrapper:
        "0.27.1/bio/trimmomatic/se"

rule trimomatic:
    input:
        get_fastq
    output:
        fastq=config["working_dir"] + "/trimmed/{sample}.fastq.gz"
    params:
        trimmer=" ".join(config["params"]["trimmomatic"]["trimmers"]),
        extra=config["params"]["trimmomatic"]["extra"]
    log:
        log_dir + "/trimmomatic/{sample}.log"
    threads:
        10
    conda:
        "../envs/trimmomatic.yaml"
    shell:
      "trimmomatic SE {params.extra} "
      "{input:q} {output:q} "
      "{params.trimmer} "
      ">{log} 2>&1"
