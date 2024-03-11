rule mosdepth_1:
    input:
        bam = "results/{refGenome}/bams/{sample}_final.bam",
        bai = "results/{refGenome}/bams/{sample}_final.bam.bai"
    output:
        dist = "results/{refGenome}/callable_sites/{sample}.1.mosdepth.global.dist.txt",
        summary = "results/{refGenome}/callable_sites/{sample}.1.mosdepth.summary.txt"
    conda:
        "../envs/cov_filter.yml"
    log:
        "logs/{refGenome}/compute_d4/{sample}.txt"
    benchmark:
        "benchmarks/{refGenome}/mosdepth_1/{sample}.txt"
    resources:
        mem_mb = lambda wildcards, attempt: attempt * resources['compute_d4']['mem'] # might need to adjust this
    threads:
        resources['compute_d4']['threads']
    params:
        prefix = os.path.join(workflow.default_remote_prefix, "results/{refGenome}/callable_sites/{sample}.1")
    shell:
        "mosdepth --no-per-base -t {threads} {params.prefix} {input.bam}"

rule mosdepth_2:
    input:
        summary = "results/{refGenome}/callable_sites/{sample}.1.mosdepth.summary.txt",
        bam = "results/{refGenome}/bams/{sample}_final.bam",
        bai = "results/{refGenome}/bams/{sample}_final.bam.bai"
    output:
        quantised = "results/{refGenome}/callable_sites/{sample}.2.quantized.bed.gz"
    conda:
        "../envs/cov_filter.yml"
    log:
        "logs/{refGenome}/compute_d4/{sample}.txt"
    benchmark:
        "benchmarks/{refGenome}/mosdepth_2/{sample}.txt"
    resources:
        mem_mb = lambda wildcards, attempt: attempt * resources['compute_d4']['mem'] # might need to adjust this
    threads:
        resources['compute_d4']['threads']
    params:
        prefix = os.path.join(workflow.default_remote_prefix, "results/{refGenome}/callable_sites/{sample}.2"),
        lower = float(config["cov_threshold_lower"]),
        upper = float(config["cov_threshold_upper"]),
        sample_mean = lambda wildcards, input: get_mean_cov(input.summary)
    shell:
        """
        export MOSDEPTH_Q0=NO_COVERAGE
        export MOSDEPTH_Q1=LOW_COVERAGE
        export MOSDEPTH_Q2=CALLABLE
        export MOSDEPTH_Q3=HIGH_COVERAGE
        mosdepth --no-per-base -t {threads} --quantize 0:1:{params.lower}:{params.sample_mean}*{params.upper}: {params.prefix} {input.bam}
        """

rule callable_bed_per_sample:
    input:
        quantised = "results/{refGenome}/callable_sites/{sample}.2.quantized.bed.gz"
    output:
        callable_bed = "results/{refGenome}/callable_sites/{sample}.callable.bed"
    conda:
        "../envs/cov_filter.yml"
    shell:
        "grep CALLABLE {input.quantised} | bedtools merge > {output.callable_bed}" # could sort here?

rule add_mappability:
    input:
        callable_bed = "results/{refGenome}/callable_sites/{sample}.callable.bed"
        #map_all = "results/{refGenome}/callable_sites/{prefix}_callable_sites_map.bed"
    output:
        callable_mappable = "results/{refGenome}/callable_sites/{sample}.callable.mappable.bed"
    conda:
        "../envs/cov_filter.yml"
    shell:
        "bedtools intersect -a {input.callable_bed} -b {input.map_all} | bedtools merge > {output.callable_mappable}"

rule callable_bed_all:
    input:
        unpack(get_all_callable_beds)
    output:
        callable_bed_all = "results/{refGenome}/callable_sites/{prefix}_all_samples_callable.bed",
        callable_mappable_bed_all = "results/{refGenome}/callable_sites/{prefix}_all_samples_callable_mappable.bed"
    params:
        get_sample_names
    conda:
        "../envs/cov_filter.yml"
    shell:
        """
        bedtools multiinter -names {params[names]} {input.callable_beds} > {output.callable_bed_all}
        bedtools multiinter -names {params[names]} {input.callable_mappable_beds} > {output.callable_mappable_bed_all}
        """
