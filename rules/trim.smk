if if_SE:
    rule trimmomatic_SE:
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
            32
        conda:
            "../envs/trimmomatic.yml"
        shell:
          "trimmomatic SE {params.extra} "
          "{input:q} {output:q} "
          "{params.trimmer} "
          ">{log} 2>&1"

else:          
    rule trimmomatic_PE:
        input:
            get_paired_fastq
        output:
            fastq1=config["working_dir"] + "/trimmed/{sample}_R1.fastq.gz",
            fastq2=config["working_dir"] + "/trimmed/{sample}_R2.fastq.gz"
        params:
            trimmer=" ".join(config["params"]["trimmomatic"]["trimmers"]),
            extra=config["params"]["trimmomatic"]["extra"]
        log:
            log_dir + "/trimmomatic/{sample}.log"
        threads:
            32
        conda:
            "../envs/trimmomatic.yml"
        shell:
          "trimmomatic PE {params.extra} "
          "{input:q} {output:q} "
          "{params.trimmer} "
          ">{log} 2>&1"
