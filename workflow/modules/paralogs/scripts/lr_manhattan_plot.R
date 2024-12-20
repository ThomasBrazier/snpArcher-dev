#!/usr/bin/env Rscript

refGenome = snakemake@params[['refGenome']]
sample = snakemake@params[['sample']]

library(ggplot2)

lr = read.table(paste0("results/", refGenome, "/paralogs/", sample, "_LR_pvalues.tsv"), sep = "\t") 