#!/usr/bin/env bash
# Shared settings for every pipeline step. Edit these for your own setup.

# Where the data lives (raw_data/, trimmed/, aligned/, etc. are created here)
PROJECT_DIR="${PROJECT_DIR:-$HOME/rnaseq_project}"

# CPU threads to use. Lower this if your machine struggles.
THREADS=8

# Sample IDs. Each sample needs raw_data/<ID>_1.fastq.gz and raw_data/<ID>_2.fastq.gz
SAMPLES=(C01 C04 C05 D02 D03 D06 F02 F05 F06 P01 P03 P05)

# Reference genome: chicken GRCg7b from Ensembl
ENSEMBL_RELEASE=115
GENOME_FA="Gallus_gallus.bGalGal1.mat.broiler.GRCg7b.dna.toplevel.fa"
GTF="Gallus_gallus.bGalGal1.mat.broiler.GRCg7b.${ENSEMBL_RELEASE}.gtf"
INDEX_PREFIX="chicken_index"

# Adapter file for Trimmomatic. This library was Nextera-prepped;
# check FastQC's overrepresented sequences before assuming TruSeq.
ADAPTERS="NexteraPE-PE.fa"

# Trimmomatic runs out of Java heap on large files with the default limit
export _JAVA_OPTIONS="-Xmx8g"
