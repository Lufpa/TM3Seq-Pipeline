rule align:
    input:
        sample="working/trimmed/{sample}.fastq.gz"
    output:
        # see STAR manual for additional output files
        accepted_hits="working/tophat2/{sample}/accepted_hits.bam",
        align_summary="working/tophat2/{sample}/align_summary.txt"
    log:
        "logs/tophat2/{sample}.log"
    params:
        output_dir="working/tophat2/{sample}",
        index=config["ref"]["index"],
        options="--GTF {} {}".format(
              config["ref"]["annotation"],
              config["params"]["tophat2"])
    threads: 24
    conda:
        "envs/tophat2.yaml
    shell:
        "tophat2 "
        "{params.options} "
        "--num-threads {threads} "
        "--output-dir {params.output_dir:q} "
        "{params.index:q} "
        "{input} >> {log:q} 2>&1"
