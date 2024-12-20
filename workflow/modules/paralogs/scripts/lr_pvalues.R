#!/usr/bin/env Rscript

refGenome = snakemake@params[['refGenome']]
sample = snakemake@params[['sample']]


lr = read.table(paste0("results/", refGenome, "/paralogs/", sample, "_calcLR.lr")) # read in ngsParalog calcLR output
lr$pval = 0.5*pchisq(lr$V5,df=1,lower.tail=FALSE) # append column of p-values
lr$pval.adj = p.adjust(lr$pval, method="bonferroni") # p-values adjusted for number of tested sites

# The 7th column of the lr data.frame is the adjusted p-value for rejecting the null hypothesis that reads
# covering the site derive from a single locus. Of course you can use any p-value adjustment of your
# choosing, e.g. "fdr".

# generate list of sites that don't show evidence of mismapping at 0.05 significance level:
# qc.sites = lr[-which(lr$pval.adj < 0.05),1:2]

# Output a bed file with LR p-values
# "#": descriptive header to add comments such as the name of each column.
# 1	chrom	Chromosome
# 2 chromStart (0-based)
# 3	chromEnd (1-based)
# 4 LR
# 5 LR p-value
# 6 LR p-value adjusted


write.table(lr, paste0("results/", refGenome, "/paralogs/", sample, "_paralogs_sites.bed"),
                sep = "\t",
                quote = FALSE,
                col.names = FALSE,
                row.names = FALSE)
