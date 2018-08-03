rule fastqc:
    input:
        get_fastq
    output:
        config["working_dir"] + "/fastqc/{sample}_fastqc.zip"
    log:
        log_dir + "/fastqc/{sample}.log"
    params:
        outdir=config["working_dir"] + "/fastqc/{sample}"
    threads: 32
    conda:
        "../envs/fastqc.yaml"
    shell:
        "mkdir -p {params.outdir:q} && "
        "fastqc --quiet "
        "--threads {threads} "
        "--outdir {params.outdir} "
        "--noextract "
        "{config[params][fastqc][extra]} "
        "{input:q} "
        ">{log:q} 2>&1 && "
        "mv '{params.outdir}/{wildcards.sample}_fastqc.zip' {output:q} && "
        "rm -rf {params.outdir:q}"
