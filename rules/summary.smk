# rule tophat_formultiqc:
#     input:
#         "working/tophat2/{sample}/align_summary.txt"
#     output:
#         temp("working/multiqc/tophat2/{sample}.align_summary.txt")
#     shell:
#         "cp {input:q} {output:q}"

rule multiqc:
    input:
        expand(log_dir + "/trimmomatic/{sample}.log", sample=samples.keys()),
        expand(config["working_dir"] + "/star/{sample}/Log.final.out", sample=samples.keys()),
        expand(config["working_dir"] + "/featurecounts/{sample}_counts.tsv.summary", sample=samples.keys()),
        expand(config["working_dir"] + "/fastqc/{sample}_fastqc.zip", sample=samples.keys())
    output:
        config["results_dir"] + "/multiqc.html"
    params:
        ""  # Optional: extra parameters for multiqc.
    log:
        log_dir + "/multiqc.log"
    conda:
        "../envs/multiqc.yaml"
    run:
        from os import path
        input_dirs = set(path.dirname(fp) for fp in input)
        output_dir = path.dirname(output[0])
        output_name = path.basename(output[0])
        shell(
            "multiqc"
            " {params}"
            " --force"
            " -o {output_dir}"
            " -n {output_name}"
            " {input_dirs}"
            " > {log:q} 2>&1")

