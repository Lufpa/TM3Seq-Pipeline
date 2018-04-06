# An example collection of Snakemake rules imported in the main Snakefile.

rule rule:
    input: "data/fastq_from_sequencer/{file}.fastq"
    output: "results/{file}.fastq_stats.txt"
    log: "results/fastq_stats/{file}.log"
    shell: 'stats ""{input}" '
            '--param value '
            '--output "{output}"
            '&> "{log}"'
