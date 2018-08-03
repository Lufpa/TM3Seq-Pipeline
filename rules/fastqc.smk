rule fastqc:
    input:
        get_fastq
    output:
        zip=config["working_dir"] + "/fastqc/{sample}_fastqc.zip",
        html=temp(config["working_dir"] + "/fastqc/{sample}_fastqc.html")
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
        # "--noextract "
        "{config[params][fastqc][extra]} "
        "{input:q} "
        ">{log:q} 2>&1 && "
        "mv '{params.outdir}/{wildcards.sample}_fastqc.zip' {output:q} && "
        "mv '{params.outdir}/{wildcards.sample}_fastqc.html' {output:q} && "
        "rm -rf {params.outdir:q}"
