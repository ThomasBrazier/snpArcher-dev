
def get_all_callable_beds(wildcards):

    _samples = samples.loc[(samples["refGenome"] == wildcards.refGenome)]["BioSample"].unique().tolist()

    names = ",".join(_samples)
    
    callable_beds = expand("results/{{refGenome}}/quantize/{sample}.callable.bed", sample=_samples)
    return {"callable_beds": callable_beds}


def get_mean_cov(summary_file):

    if not Path(summary_file).exists():
        return -1

    with open(summary_file, "r") as f:
        for line in f:
            if line.startswith("total"):
                sample_mean = float(line.split("\t")[3])

    return sample_mean


def get_sample_names(wildcards):

    _samples = samples.loc[(samples["refGenome"] == wildcards.refGenome)]["BioSample"].unique().tolist()
    names = ",".join(_samples)
    
    return names


def get_sample_size(wildcards):

    _samples = samples.loc[(samples["refGenome"] == wildcards.refGenome)]["BioSample"].unique().tolist()
    sample_size = len(_samples)
    
    return sample_size