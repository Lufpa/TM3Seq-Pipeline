rule count:
    input:
        gtf=config["ref"]["annotation"],
        bam=config["working_dir"] + "/nudup/{sample}.sorted.markdup.bam" if {config["umi"]["mark_umi_duplicates"]} else config["working_dir"] + "/star/{sample}/Aligned.sortedByCoord.out.bam"
    output:
        counts=config["working_dir"] + "/featurecounts/{sample}_counts.tsv",
        summary=config["working_dir"] + "/featurecounts/{sample}_counts.tsv.summary"
    log:
        log_dir + "/featurecounts/{sample}.log"
    threads:
        8
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

rule combined_counts:
    input:
        expand(config["working_dir"] + "/featurecounts/{sample}_counts.tsv",
               sample=samples.keys())
    output:
        config["results_dir"] + "/combined_gene_counts.tsv"
    run:
        shell("cp {input[0]:q} {output:q}")
        for f in input:
            shell("cp {output:q} tmp")
            shell("cut -f 7 {f:q} | paste tmp - > {output:q}")
        shell("rm tmp")
