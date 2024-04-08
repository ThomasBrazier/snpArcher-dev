library(rCNV)
library(ggplot2)
# https://piyalkarum.github.io/rCNV/articles/rCNV.html
# https://doi.org/10.1101/2022.10.14.512217


refGenome = snakemake@params[['refGenome']]
prefix = snakemake@params[['prefix']]

vcf.file.path = paste0("results/", refGenome, "/", prefix, "_raw.vcf.gz")
vcf = readVCF(vcf.file.path, verbose = FALSE)

# Generating allele depth tables and normalized depth values 
ad.tab = hetTgen(vcf, info.type="AD")
ad.tab[1:10,1:6]

#the genotype table is needed for correcting the genotype mismatches
gt = hetTgen(vcf, info.type = "GT")
ad.tab = ad.correct(ad.tab, gt.table = gt)

#normalize depth table with cpm.normal()
ad.nor = cpm.normal(ad.tab,method="MedR")
ad.nor[1:6,1:6]

# DETECTION
A.info = allele.info(X = ADtable, x.norm = ADnorm, plot.allele.cov = TRUE)
# X is the corrected non-normalized allele depth table and x.norm is the normalized allele depth table
head(A.info)

# Deviants detection
# Run this code for a demonstration of the detection
dvs = dupGet(alleleINF, test = c("z.05","chi.05"))
# z score and chi-square values given p=0.05 is used here because the data is RADseq generated and probe-biase is neglegible

head(dvs)

deviants = dupGet(alleleINF, test = c("z.all","chi.all"), plot = F, verbose = TRUE)
head(deviants)

# Save deviant table
write.table(deviants, paste0("results/", refGenome, "/paralogs/rCNV/", prefix, "_deviants.tsv"), quote = F, rownames = F, colnames = T, sep = "\t")

# Plot deviants: Allele median ratio Vs Proportion of Heterozygotes
p = dup.plot(deviants)
ggsave(paste0("results/", refGenome, "/paralogs/rCNV/", prefix, "_deviants.jpeg"), p, width = 12, height = 9)

# Filtering putative CNVs
# SNPs that are located in putative CNV regions are filtered using two methods;
# 1) intersection: using a combination of at least two statistics used in deviant detection.
# i.e., excess of heterozygotes, Z-score distribution and Chi-square distribution,
# 2) K-means: using an unsupervised clustering based on Z-score, chi-square, excess of heterozygotes,
# and coefficient of variation from read-depth dispersion.
# The significant SNPs from either of the filtering are flagged as putative duplicates.
# The users can pick a range of optimal statistics (e.g. z.all,chi.all,z.05,chi.05, etc.)
# depending on the nature (also sequencing technology) of the underlying data.
# The function cnv() is dedicated for this purpose.
CNV = cnv(alleleINF, test=c("z.05","chi.05"), filter = "kmeans")

# see the difference between deviants and duplicates
table(deviants$dup.stat)
table(CNV$dup.stat)


# Save CNV table
write.table(CNV, paste0("results/", refGenome, "/paralogs/rCNV/", prefix, "_CNV.tsv") , quote = F, rownames = F, colnames = T, sep = "\t")

# Plot CNV: Allele median ratio Vs Proportion of Heterozygotes
p = dup.plot(CNV)
ggsave(paste0("results/", refGenome, "/paralogs/rCNV/", prefix, "_CNV.jpeg"), p, width = 12, height = 9)