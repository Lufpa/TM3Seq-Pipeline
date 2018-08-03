rule fastqc:
    input:
        get_fastq
    output:
        html=config["working_dir"] + "/fastqc/{sample}.html",
        zip=config["working_dir"] + "/fastqc/{sample}_fastqc.zip"
    log:
        log_dir + "/fastqc/{sample}.log"
    params: ""
    wrapper:
        "0.27.1/bio/fastqc"
