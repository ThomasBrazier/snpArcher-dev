def get_chr_list(fai_path:str):
    """Return the list of scf that will be analyzed

    Args:
        fai_path (str): tab separated table (fai format). 
                        Genome info, with only scf that will be analyzed
    Returns:
        list of scaffolds of interest
    """

    return [row.strip().split('\t')[0] for row in open(fai_path, "r")]