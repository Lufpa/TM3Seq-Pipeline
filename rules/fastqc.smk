rule fastqc:
    input:
        get_fastq
    output:
        html=config["working_dir"] + "/fastqc/{sample}.html",
        zip=config["working_dir"] + "/fastqc/{sample}_fastqc.zip"
    params: ""
    wrapper:
        "0.23.1/bio/fastqc"
