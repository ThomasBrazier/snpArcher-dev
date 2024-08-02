#!/bin/bash
#SBATCH -J sm
#SBATCH -o slurm/slurm-%j.out
#SBATCH -e slurm/slurm-%j.err
#SBATCH -p long
#SBATCH -n 1
#SBATCH -t 9000
#SBATCH --mem=10000
#SBATCH --mail-user=thomas.brazier@univ-rennes.fr
#SBATCH --mail-type=all
#SBATCH --time=25-60:00:00
#SBATCH --job-name=snparcher-test



# CONDA_BASE=$(conda info --base)
# source $CONDA_BASE/etc/profile.d/conda.sh
# conda activate snakemake
module load snakemake
snakemake --snakefile workflow/Snakefile --profile ./profiles/slurm --use-conda --conda-prefix /shared/projects/landrec/snpArcher-dev/.conda  --forcerun paralogs_rCNV