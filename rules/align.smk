import os
genome_index_base, fasta_extension = os.path.splitext(config["ref"]["fasta"])
# genome_index_base = re.sub('\.fasta$|\.fa$', '', config["ref"]["fasta"])
transcriptome_index_base = "{}_transcriptome_index".format(genome_index_base)


rule genome_index:
    input:
        fasta="{genome}" + fasta_extension
    output:
        "{genome}.1.bt2",
        "{genome}.2.bt2",
        "{genome}.3.bt2",
        "{genome}.4.bt2",
        "{genome}.rev.1.bt2",
        "{genome}.rev.2.bt2"
    log:
        "logs/bowtie2/genome_index.log"
    threads: 8
    conda:
        "../envs/bowtie2.yaml"
    shell:
        "bowtie2-build --threads {threads} {input:q} {wildcards.genome:q}  >{log:q} 2>&1"


rule transcriptome_index:
    input:
        bowtie2_index="{}.rev.2.bt2".format(genome_index_base),
        gtf=config["ref"]["annotation"]
    output:
        "{}.1.bt2".format(transcriptome_index_base),
        "{}.2.bt2".format(transcriptome_index_base),
        "{}.3.bt2".format(transcriptome_index_base),
        "{}.4.bt2".format(transcriptome_index_base),
        "{}.rev.1.bt2".format(transcriptome_index_base),
        "{}.rev.2.bt2".format(transcriptome_index_base)
    params:
        bowtie_index=genome_index_base,
        transcriptome_index=transcriptome_index_base
    log:
        "logs/tophat2/transcriptome_index.log"
    threads: 8
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
        genome_index="{}.rev.2.bt2".format(genome_index_base),
        transcriptome_index="{}.rev.2.bt2".format(transcriptome_index_base)
    output:
        accepted_hits="working/tophat2/{sample}/accepted_hits.bam",
        align_summary="working/tophat2/{sample}/align_summary.txt"
    log:
        "logs/tophat2/{sample}.log"
    params:
        output_dir="working/tophat2/{sample}",
        transcriptome_index=transcriptome_index_base,
        index=genome_index_base,
        options=config["params"]["tophat2"]
    threads: 8
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

rule rename_tophat_output:
    input:
        "working/tophat2/{sample}/{file}"
    output:
        "working/multiqc/tophat2/{sample,\w[^_]+}.{file}"
    run:
        (bn, fn) = os.path.split(output[0])
        shell("""cd {bn}
              ln -s "../../../{input}" "{fn}" """)
