# snpArcher

<img src="./docs/img/logo.png" alt="snpArcher logo" height="300"/>


snpArcher is a reproducible workflow optimized for nonmodel organisms and comparisons across datasets, built on the [Snakemake](https://snakemake.readthedocs.io/en/stable/index.html#) workflow management system. It provides a streamlined approach to dataset acquisition, variant calling, quality control, and downstream analysis.


## Fork of snpArcher

This is a fork of the original SNPArcher to add new features, including:
* make fastq and bam as temporary files to scale up to large datasets in smaller clusters (input fastq and intermediate bam files are removed on a per sample basis)
* the `quantize_cov` module implementing the `mosdepth` quantize method as described in Laetsch et al. (2023)
* the `paralogs` module to detect and annotate SNPs that are putative Copy Number Variations, based on the `rCNV` method (Karunarathne et al. 2023)


### Install

```
conda activate snakemake
snakemake -d .test/ecoli --cores 1 --use-conda
```

### Usage

You first need to make a working directory, either within or outside the snpArcher directory.

Within your working directory, you need to copy the `config/` directory and modify the settings (usually `config.yaml` and `samples.csv`) according to your analyses. You can add multiple sub-directories if you wish to run multiple datasets in parallel (e.g. `<your working directory>/<your dataset>/`). Snakemake will install a `.snakemake` config directory at the first run to install conda envs (it can take time).

Run the analyses from the snpArcher directory with :

```
snakemake --snakefile workflow/Snakefile --use-conda --cores <number of cores> --printshellcmds -d <your working directory>/<your dataset>/
```



## New Features and Development


### Module Quantize_cov



the lower threshold is the absolute number of reads required for callability
the upper threshold is in terms of the sample-specific mean coverage (i.e. upper = upper * mean coverage)
this approach uses mosdepth quantize as in Laetsch et al. (2023)


This module produces different BED files to filter SNPs per sample (gVCF) or for the entire dataset (final VCF).
- per site, information on the callability/mappability on average and per sample. This BED is intended to annotate and filter SNPs independently.
- genomic regions, with summarized information on the callability/mappability on average and per sample. This BED file is intended to mask regions of the genome or to calculate the proportion of the genome that is not mappable/callable.


The idea of this module is to easily get all the information to account for heterogeneity in callability/mappability along the genome, and to be able to subsequently filter SNPS or mask sites or entire genomic regions in downstream analyses.



¨MOSDEPTH_Q0=NULL; export MOSDEPTH_Q1=LOW; export MOSDEPTH_Q2=CALLABLE; export MOSDEPTH_Q3=HIGH && mosdepth -t {parameterObj.threads} -n --quantize 0:1:{min_depth}:{max_depth}: {tmp_prefix} {bam_path}"¨

- {CALLABLE_SITES}   := for each BAM, regions along which sample read depths lie within coverage thresholds.
- {CALLABLES}        := bedtools multiintersect of all {CALLABLE_SITES} regions across all BAMs/samples
- {FAIL_SITES}       := sites excluded due to {FAIL} variant set (during VCF processing)
- {SITES}            := {CALLABLES} - {FAIL_SITES}


#### Output files

The final BED file is the multi-intersect of callable sites (mosdepth method) and mappable sites (genmap method).


### Module Paralogs


Identify:
- SNPs that are putative pseudo-heterozygotes due to CNVs (called deviants in the rCNV method). A ‘CNV’ SNP is categorized as a putative CNV if it is supported by at least two of the statistics (based on their p-values) and by the K-means clustering method (which is independent of thresholds and cut-off values).
- deviant SNPs that are not statistically supported as CNVs, but are flagged as outliers and less reliable than other SNPs called. Let the user decide if he wants to remove these deviant SNPs or not.
- multicopy regions, based on a sliding windows approach.

`rCNV` is set with the recommended parameters for WGS data.



Note:
It is recommended to perform Hardy-Weinberg equilibrium tests on sites as a basic filtering on the final dataset. However, it is easy to do and we did not implement this basic function.


#### Output files

* `paralogs/rCNV/*_allele_info.tsv`, the summary statistics per site which are used to classify SNPs as deviants/CNVs
* `paralogs/rCNV/*_deviants.tsv` and `.BED`, deviant sites, a set of sites showing departure from the expected allele ratio (useful to prune a SNP dataset to remove pseudo-heterozygotes and putative multicopy regions)
* `paralogs/rCNV/*_CNV.tsv` and `.BED`, CNV sites, a set of confidently assessed CNVs (useful to annotate sites present in multicopy regions and to detect these regions)
* `paralogs/rCNV/*_duplicates.tsv`, sliding windows along the chromosome, with the count of duplicate and singlet sites
* `paralogs/rCNV/*_rCNV.html`, an HTML report on the full rCNV analysis


Low confidence sites can be deduced by substracting CNV sites to the deviant sites (sites that are not statistically identified as CNVs but are outliers showing departure from the expected allele ratio).



## snpArcher Original

### Usage
For usage instructions and complete documentation, please visit our [docs](https://snparcher.readthedocs.io/en/latest/).

### Datasets generated by snpArcher
A number of resequencing datasets have been run with snpArcher generating consistent variant calls, available via [Globus](https://www.globus.org/) in the [Comparative Population Genomics Data collection](https://app.globus.org/file-manager?origin_id=a6580c44-09fd-11ee-be16-195c41bc0be4&origin_path=%2F). Details of data processing are described [in our manuscript](https://www.biorxiv.org/content/10.1101/2023.06.22.546168v1). If you use any of these datasets in your projects, please cite both the [snpArcher paper](https://www.biorxiv.org/content/10.1101/2023.06.22.546168v1) and the original data producers.

### Citing snpArcher
- Cade D Mirchandani, Allison J Shultz, Gregg W C Thomas, Sara J Smith, Mara Baylis, Brian Arnold, Russ Corbett-Detig, Erik Enbody, Timothy B Sackton, A fast, reproducible, high-throughput variant calling workflow for population genomics, Molecular Biology and Evolution, 2023;, msad270, https://doi.org/10.1093/molbev/msad270
- Also, make sure to cite the tools you used within snpArcher.




## References

Babadi, M., Fu, J. M., Lee, S. K., Smirnov, A. N., Gauthier, L. D., Walker, M., Benjamin, D. I., Zhao, X., Karczewski, K. J., Wong, I., Collins, R. L., Sanchis-Juan, A., Brand, H., Banks, E., & Talkowski, M. E. (2023). GATK-gCNV enables the discovery of rare copy number variants from exome sequencing data. Nature Genetics, 55(9), 1589‑1597. https://doi.org/10.1038/s41588-023-01449-0


Karunarathne, P., Zhou, Q., Schliep, K., & Milesi, P. (2023). A comprehensive framework for detecting copy number variants from single nucleotide polymorphism data : ‘rCNV’, a versatile r package for paralogue and CNV detection. Molecular Ecology Resources, 23(8), Article 8. https://doi.org/10.1111/1755-0998.13843


Laetsch, D. R., Bisschop, G., Martin, S. H., Aeschbacher, S., Setter, D., & Lohse, K. (2023). Demographically explicit scans for barriers to gene flow using gIMble. PLOS Genetics, 19(10), Article 10. https://doi.org/10.1371/journal.pgen.1010999
