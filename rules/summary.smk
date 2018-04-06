# rule tophat_formultiqc:
#     input:
#         "working/tophat2/{sample}/align_summary.txt"
#     output:
#         temp("working/multiqc/tophat2/{sample}.align_summary.txt")
#     shell:
#         "cp {input:q} {output:q}"

rule multiqc:
    input:
        expand("logs/trimmomatic/{sample}.log", sample=samples.keys()),
        expand("working/multiqc/tophat2/{sample}.align_summary.txt", sample=samples.keys()),
        expand("working/featurecounts/{sample}_counts.tsv.summary", sample=samples.keys()),
        expand("working/fastqc/{sample}_fastqc.zip", sample=samples.keys())
    output:
        config["results_dir"] + "/multiqc.html"
    params:
        "-e bowtie2 "  # Optional: extra parameters for multiqc.
    log:
        "logs/multiqc.log"
    wrapper:
        "0.23.1/bio/multiqc"
