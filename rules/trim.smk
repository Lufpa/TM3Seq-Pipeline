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
        "0.23.1/bio/trimmomatic/se"
