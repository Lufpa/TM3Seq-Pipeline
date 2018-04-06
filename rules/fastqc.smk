rule fastqc:
    input:
        get_fastq
    output:
        html="working/fastqc/{sample}.html",
        zip="working/fastqc/{sample}_fastqc.zip"
    params: ""
    wrapper:
        "0.23.1/bio/fastqc"
