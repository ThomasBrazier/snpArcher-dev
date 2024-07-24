#!/usr/bin/env Rscript

refGenome = snakemake@params[['refGenome']]
prefix = snakemake@params[['prefix']]
minMissSample = snakemake@params[['minMissSample']]
minMissSNP = snakemake@params[['minMissSNP']]

rmarkdown::render('workflow/modules/paralogs/scripts/rcnv.Rmd',
                    output_file = paste0("results/", refGenome, "/paralogs/rCNV/", prefix, "_rCNV.html"),
                    output_dir = paste0(wdir),
                    params = list(refGenome = refGenome,
                    prefix = prefix,
                    maxMissSample = maxMissSample,
                    maxMissSNP = maxMissSNP,
                    maxRelatedness = maxRelatedness))
