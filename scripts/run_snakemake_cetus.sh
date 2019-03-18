#!/bin/bash

# TODO Check for existence of config.yml and cluster.yml

# TODO Optional parameters to specify config and cluster files

export DRMAA_LIBRARY_PATH=/usr/local/slurm/16.05.8/lib/libdrmaa.so

snakemake --cluster-config 'cluster_config.cetus.yml' \
          --drmaa " --cpus-per-task={cluster.n} --mem={cluster.memory} --qos={cluster.qos} --time={cluster.time}" \
          --use-conda -w 60 -rp -j 500 "$@"
