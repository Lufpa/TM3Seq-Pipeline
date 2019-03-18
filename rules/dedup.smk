from tempfile import TemporaryDirectory

rule nudup:
    input:
        config["working_dir"] + "/star/{sample}/Aligned.sortedByCoord.out.bam"
    params:
        output_prefix=config["working_dir"] + "/nudup/{sample}",
        tmp_dir=config["params"]["nudup"]["tmp_dir"] + "/{sample}"
    output:
        dedup=temp(config["working_dir"] + "/nudup/{sample}.sorted.dedup.bam"),
        markdup=config["working_dir"] + "/nudup/{sample}.sorted.markdup.bam"
    log:
        log_dir + "/nudup/{sample}.log"
    conda:
        "../envs/nudup.yml"
    shell:
        "mkdir -p {params.tmp_dir:q} && "
        "nudup.py "
        "-o {params.output_prefix} "
        "-s {config[params][nudup][umi_start]} "
        "-l {config[params][nudup][umi_length]} "
        "-T {params.tmp_dir:q}"
        "{config[params][nudup][extra]} "
        "{input:q} "
        ">{log:q} 2>&1 && "
        "rm -rf {params.tmp_dir:q}"
