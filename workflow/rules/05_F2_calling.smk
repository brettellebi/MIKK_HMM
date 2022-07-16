# Get read counts supporting each F0-homozygous-divergent allele
rule bam_readcount_F2:
    input:
        bam = rules.merge_bams.output.bam,
        index = rules.samtools_index.output,
        sites_file = rules.extract_homo_div_snps.output.sites,
        ref = rules.get_genome.output,
    output:
        os.path.join(
            config["workdir"],
            "dp4s/F2/hdrr/{sample}_{pat}_{mat}.dp4.txt"
        ),
    log:
        os.path.join(
            config["workdir"],
            "logs/bam_readcount_F2/hdrr/{sample}_{pat}_{mat}.log"
        ),
    resources:
        mem_mb = 200
    container:
        config["bam-readcount"]
    shell:
        """
        bam-readcount \
            -l {input.sites_file} \
            -f {input.ref} \
            {input.bam} | \
            cut -f 1,15,28,41,54,67 -d ":" | sed 's/=//g' | sed 's/\\t:/\\t/g' | sed 's/:/\\t/g' \
                > {output} 2> {log}
        """

# Make dpAB files
rule make_dp_AB_F2:
    input:
        dp4 = rules.bam_readcount_F2.output,
        sites_file = rules.extract_homo_div_snps.output.sites,
    output:
        os.path.join(
            config["workdir"],
            "dpABs/F2/hdrr/{sample}_{pat}_{mat}.txt"
        ),
    log:
        os.path.join(
            config["workdir"],
            "logs/make_dp_AB_F2/hdrr/{sample}_{pat}_{mat}.log"
        ),
    resources:
        mem_mb = 2000
    script:
        "../scripts/make_dp_AB.py"

# Create HMM inputs
rule make_hmm_input:
    input:
        expand(rules.make_dp_AB_F2.output,
            zip,
            sample = SAMPLES_ZIP,
            pat = PAT_ZIP,
            mat = MAT_ZIP
        ),
    output:
        os.path.join(
            config["workdir"],
            "hmm_in/F2/hdrr/{bin_length}.csv"
        ),
    log:
        os.path.join(
            config["workdir"],
            "logs/make_hmm_input/hdrr/{bin_length}.log"
        ),
    params:
        bin_length = "{bin_length}",
    resources:
        mem_mb = 7000
    container:
        config["R_4.2.0"]
    script:
        "../scripts/make_hmm_input.R"

