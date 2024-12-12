#!/usr/bin/env Rscript

refGenome = snakemake@params[['refGenome']]
prefix = snakemake@params[['prefix']]
maxMissSample = snakemake@params[['maxMissSample']]
maxMissSNP = snakemake@params[['maxMissSNP']]
maxRelatedness = snakemake@params[['maxRelatedness']]


rmarkdown::render('workflow/modules/paralogs/scripts/rcnv.Rmd',
                    output_file = paste0("results/", refGenome, "/paralogs/rCNV/", prefix, "_rCNV.html"),
                    output_dir = paste0("results/", refGenome, "/paralogs/rCNV"),
                    params = list(refGenome = refGenome,
                    prefix = prefix,
                    maxMissSample = maxMissSample,
                    maxMissSNP = maxMissSNP,
                    maxRelatedness = maxRelatedness))
