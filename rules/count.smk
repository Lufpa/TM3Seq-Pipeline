rule count:
    input:
        gtf=config["ref"]["annotation"],
        bam="working/multiqc/tophat2/{sample}.accepted_hits.bam"
    output:
        counts="working/featurecounts/{sample}_counts.tsv",
        summary="working/featurecounts/{sample}_counts.tsv.summary"
    log:
        "logs/featurecounts/{sample}.log"
    threads: 8
    conda:
        "../envs/subread.yaml"
    shell:
        "featureCounts "
            "-t {config[params][featurecounts][feature_type]} "
            "-g {config[params][featurecounts][attribute_type]} "
            "-a {input.gtf:q} "
            "{config[params][featurecounts][extra]} "
            "-T {threads} "
            "-o {output.counts:q} "
            "{input.bam:q} "
            ">{log:q} 2>&1"
