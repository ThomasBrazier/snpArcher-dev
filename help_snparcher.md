# snpArcher quick notice

## Install
Install github project

```
git clone https://github.com/ThomasBrazier/snpArcher-dev.git

cd snpArcher-dev
git checkout ngsparalog # use version with ngsparalog
git checkout -b ngsparalog-max # new branch to run with my personal configs
```

You'll also need to install ngsparalog, it's not include inside snakemake for now
```
git clone https://github.com/tplinderoth/ngsParalog.git
```

Then create conda env with snakemake from yaml file
```
conda env create -f snparcher.yaml
```

## snpArcher preparation

### Sampling

You need to select a dataset of resequenced data and a reference genome.
Either absolute path of sequences if in local or ncbi accessions (see [snpArcher doc](https://snparcher.readthedocs.io/en/latest/setup.html))

There is a list of data features we need to check before running snpArcher:
- Chromosome level assembly or the reference genome
- Same reference genome used for the recombination map
- The genome must be annotated (.gff file)
- How many samples you selected and how long is the genome
- Coverage and Depth of the dataset if already snp-called in a previous study (can help to filter out bad samples)

Use script prepare_samplesheet.py to properly prepare the input file

### Config file

Our config file changed compare to original repo. See **/projects/plantlp/01_SNP_CALLING/data/config/**template.yaml as a template.
Precise absolute paths !

### Profile file

Important to set a precise profile.yaml file for each run to optimize the execution (save time and ressources).
The amount of time and ressources will depend of the size of the dataset but mostly of the size of the genome (more bam2gvcf rules and longer)

## Run snpArcher

You first need to create the directory before and copy the config.yaml in dir/config/config.yaml

You should always start by a dry-run to check if everything is fine
```
  snakemake -s snpArcher-dev/workflow/Snakefile \
    -d $dir \
    --workflow-profile snpArcher-dev/profiles/slurm \
    --dry-run
```

Then I suggest to use this command:

```
  snakemake -s snpArcher-dev/workflow/Snakefile \
    -d $dir \
    --workflow-profile snpArcher-dev/profiles/slurm \
    --use-conda \
    --conda-frontend conda
```

This allows to run in a specific directory outside snpArcher repo.
And to keep track of config files outside and have a clean output directory (imo)

The script **01_SNP_CALLING/scripts/go_snparcher.sh** does all of that. You should copy it on your scratch and, inside the script, set the path to your snparcher directory.

## Check the ongoing analysis

In the output directory you have files in dir/.snakemake/log to follow the analysis. This leads to rule specific log files.\
There's also the benchmark directory to follow the mean time and ressources used by each rules.\
You'll sometime need to increase ressources in the profile file and rerun. In that case, most the time, snakemake will ask you to add ```--unlock``` or ```--rerun-incomplete``` to the command.