rule transcriptome_index:
    input:
        gtf=config["ref"]["annotation"]
    output:
        "working/reference/transcriptome_index.rev.2.bt2"
    params:
        bowtie_index=config["ref"]["index"],
        transcriptome_index="working/reference/transcriptome_index"
    log:
        "logs/tophat2/transcriptome_index.log"
    threads: 24
    conda:
        "../envs/tophat2.yaml"
    shell:
        "tophat2 "
        "--num-threads {threads} "
        "--GTF {input.gtf:q} "
        "--transcriptome-index={params.transcriptome_index:q} "
        "{params.bowtie_index:q} >{log:q} 2>&1"


rule align:
    input:
        fastq="working/trimmed/{sample}.fastq.gz",
        transcriptome_index="working/reference/transcriptome_index.rev.2.bt2"
    output:
        # see STAR manual for additional output files
        accepted_hits="working/tophat2/{sample}/accepted_hits.bam",
        align_summary="working/tophat2/{sample}/align_summary.txt"
    log:
        "logs/tophat2/{sample}.log"
    params:
        output_dir="working/tophat2/{sample}",
        transcriptome_index="working/reference/transcriptome_index",
        index=config["ref"]["index"],
        options=config["params"]["tophat2"]
    threads: 24
    conda:
        "../envs/tophat2.yaml"
    shell:
        "tophat2 "
        "{params.options} "
        "--no-novel-juncs "
        "--transcriptome-index {params.transcriptome_index:q} "
        "--num-threads {threads} "
        "--output-dir {params.output_dir:q} "
        "{params.index:q} "
        "{input.fastq} >{log:q} 2>&1"
