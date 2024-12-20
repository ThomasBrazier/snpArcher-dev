# snpArcher

<img src="./docs/img/logo.png" alt="snpArcher logo" height="300"/>


snpArcher is a reproducible workflow optimized for nonmodel organisms and comparisons across datasets, built on the [Snakemake](https://snakemake.readthedocs.io/en/stable/index.html#) workflow management system. It provides a streamlined approach to dataset acquisition, variant calling, quality control, and downstream analysis.


## Fork of snpArcher

This is a fork of the original SNPArcher to add new features, including:
* make fastq and bam as temporary files to scale up to large datasets in smaller clusters (input fastq and intermediate bam files are removed on a per sample basis)
* the `quantize_cov` module implementing the mosdepth quantize method as in Laetsch et al. (2023)


## Install

Use the same procedure as for the original SNPArcher repository. See the [docs](https://snparcher.readthedocs.io/en/latest/).

Briefly:

```
conda activate snakemake
snakemake -d .test/ecoli --cores 1 --use-conda
```

## Usage


### How to configure the repo for your analyses - Git branching

First of all, you need to configure your repository for analyses. Please avoid changing directly the config files and committing changes to the main branch, otherwise other users will be affected by your commits. In order to work properly with parallel settings (for each user), it is strongly recommended to use branching.

Eash user has to make its own branch, and commit changes to config files only in its own branch. This branch should NEVER be merged with main branch. Hence each user can work with it own settings in isolation. Another advantage is that the user will not be affected by upstream commits (i.e. updates in the pipeline), unless he explicitly merge his branch with upstream `main` branch.

```
git branch myownconfigname
git checkout myownconfigname
```


[Branching in a nutshell](https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell)
[Github branching documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository)


### Working directory and data


You also need to make a working directory, either within or outside the snpArcher directory. If it is outside, you don't care of the above branching recommendations.

Within your working directory you need to copy the `config/` directory and modify the settings (usually `config.yaml` and `samples.csv`) according to your analyses. You can add multiple sub-directories if you wish to run multiple datasets in parallel (e.g. `<your working directory>/<your dataset>/`). Snakemake will install a `.snakemake` config directory at the first run to install conda envs (it can take times).

In addition, you can modify the `profiles/slurm/config.yaml` in place (since you are on your own branch) or copy it to your working directory.

A recommended architecture is the following:

```
.
├── snparcher-dev/
│   ├── config/
│   │   ├── config.yaml <default config file>
|   ├── profiles/
|   |   ├── slurm/
│   |   |   ├── config.yaml <default slurm profile>
│   ├── workflow/
│   ├── data/
|   |   ├── config/
│   │   |   ├── config.yaml <your own config file>
|   |   ├── profiles/
|   |   |   ├── slurm/
│   │   |   |   ├── config.yaml <your own slurm profile>
```



Run the analyses from the snpArcher directory with :

```
snakemake --snakefile workflow/Snakefile --use-conda --cores <number of cores> --printshellcmds --profile <your working directory>/profiles/slurm/config.yaml -d <your working directory>/<your dataset>/
```





## New Features and Development


### Temporary BAM files

BAM files are now marked as temporary files, and are removed as soon as they have been used by the last rule calling them. It should improve pipeline scalability by freeing storage space earlier in the process.

### Module Quantize_cov

```
Laetsch, D. R., Bisschop, G., Martin, S. H., Aeschbacher, S., Setter, D., & Lohse, K. (2023). Demographically explicit scans for barriers to gene flow using gIMble. PLoS genetics, 19(10), e1010999.
```

[mosdepth](https://github.com/brentp/mosdepth)


### Module Paralogs (work in progress - not in main branch)

Mismapped reads and structural variants can be called as fake SNPs. We use the ngsParalog software to detect deviant SNPs as in Dallaire et al. 2023.



```
Dallaire, Xavier, Raphael Bouchard, Philippe Hénault, Gabriela Ulmo-Diaz, Eric Normandeau, Claire Mérot, Louis Bernatchez, et Jean-Sébastien Moore. « Widespread Deviant Patterns of Heterozygosity in Whole-Genome Sequencing Due to Autopolyploidy, Repeated Elements, and Duplication ». Édité par Andrea Betancourt. Genome Biology and Evolution 15, nᵒ 12 (1 décembre 2023): evad229. https://doi.org/10.1093/gbe/evad229.
```

Output files:
* "results/{refGenome}/paralogs/{sample}_paralogs_sites.bed"
* "results/{refGenome}/paralogs/{sample}_paralogs_region.bed"



## snpArcher Original

### Usage
For usage instructions and complete documentation, please visit our [docs](https://snparcher.readthedocs.io/en/latest/).

### Datasets generated by snpArcher
A number of resequencing datasets have been run with snpArcher generating consistent variant calls, available via [Globus](https://www.globus.org/) in the [Comparative Population Genomics Data collection](https://app.globus.org/file-manager?origin_id=a6580c44-09fd-11ee-be16-195c41bc0be4&origin_path=%2F). Details of data processing are described [in our manuscript](https://www.biorxiv.org/content/10.1101/2023.06.22.546168v1). If you use any of these datasets in your projects, please cite both the [snpArcher paper](https://www.biorxiv.org/content/10.1101/2023.06.22.546168v1) and the original data producers.

### Citing snpArcher
- Cade D Mirchandani, Allison J Shultz, Gregg W C Thomas, Sara J Smith, Mara Baylis, Brian Arnold, Russ Corbett-Detig, Erik Enbody, Timothy B Sackton, A fast, reproducible, high-throughput variant calling workflow for population genomics, Molecular Biology and Evolution, 2023;, msad270, https://doi.org/10.1093/molbev/msad270
- Also, make sure to cite the tools you used within snpArcher.
