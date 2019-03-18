import os
genome_index_base, fasta_extension = os.path.splitext(config["ref"]["fasta"])
genome_basename = os.path.basename(genome_index_base)
star_genome_dir = os.path.join(os.path.dirname(config["ref"]["fasta"]), genome_basename + "_star_index")


rule star_genome_index:
    input:
        fasta=config["ref"]["fasta"]
    output:
        directory(star_genome_dir)
    log:
        log_dir + "/star/genome_index.log"
    threads: 32
    conda:
        "../envs/star.yml"
    shell:
        "mkdir -p {output:q} && "
        "STAR --runMode genomeGenerate "
        "--genomeFastaFiles {input.fasta:q} "
        "--genomeDir {output:q} "
        "--sjdbGTFfile {config[ref][annotation]:q} "
        "--sjdbOverhang 100 "
        "--runThreadN {threads} "
        ">{log:q} 2>&1"


rule star_align:
    input:
        fastq=config["working_dir"] + "/trimmed/{sample}.fastq.gz",
        genome_index=star_genome_dir
    output:
        bam=config["working_dir"] + "/star/{sample}/Aligned.sortedByCoord.out.bam",
        log=config["working_dir"] + "/star/{sample}/Log.final.out"
    params:
        prefix=config["working_dir"] + "/star/{sample}/"
    log:
        log_dir + "/star/{sample}.log"
    threads: 32
    conda:
        "../envs/star.yml"
    shell:
        "STAR "
        "{config[params][star][extra]} "
        "--runThreadN {threads} "
        "--genomeDir {input.genome_index:q} "
        "--readFilesIn {input.fastq:q} "
        "--readFilesCommand {config[params][star][zcat_command]} "
        "--outSAMtype BAM SortedByCoordinate "
        "--outFileNamePrefix {params.prefix:q} "
        "--outStd Log "
        ">{log:q} 2>&1"
