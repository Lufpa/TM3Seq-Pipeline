# rule tophat_formultiqc:
#     input:
#         "working/tophat2/{sample}/align_summary.txt"
#     output:
#         temp("working/multiqc/tophat2/{sample}.align_summary.txt")
#     shell:
#         "cp {input:q} {output:q}"

from os import path

#def get_multiqc_dirs(wildcards):
#    return set(path.dirname(fp) for fp in wildcards.input)
#    return samples[wildcards.sample]


rule multiqc:
    input:
        expand(log_dir + "/trimmomatic/{sample}.log", sample = SAMPLES_ALL if if_SE else SAMPLES_PAIRED),
        expand(config["working_dir"] + "/star/{sample}/Log.final.out", sample = SAMPLES_ALL if if_SE else SAMPLES_PAIRED),
        expand(config["working_dir"] + "/featurecounts/{sample}_counts.tsv.summary", sample = SAMPLES_ALL if if_SE else SAMPLES_PAIRED),
        expand(config["working_dir"] + "/fastqc/{sample}_fastqc.zip", sample=SAMPLES_ALL)
    output:
        config["results_dir"] + "/multiqc.html"
    params:
        multiqc="--cl-config \"trimmomatic: {s_name_filenames: true}\"",  # Optional: extra parameters for multiqc.
        output_dir=config['results_dir'],
        output_name="multiqc.html"
    log:
        log_dir + "/multiqc.log"
    conda:
        "../envs/multiqc.yml"
    shell:
        "multiqc"
        " {params.multiqc}"
        " --force"
        " -o {params.output_dir:q} "
        " -n {params.output_name:q} "
        " {input:q}"
        " > {log:q} 2>&1"
