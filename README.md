# RNA-seq Pipeline: Raw Reads to Differential Expression

A bulk RNA-seq workflow for paired-end Illumina data, from raw FASTQ files to differentially expressed genes. Built for whole chicken embryo samples aligned to the GRCg7b genome, but adaptable to other organisms by changing the reference in `scripts/config.sh`.

Based on the protocol in Shouib et al. (2025), *A Guide to Basic RNA Sequencing Data Processing and Transcriptomic Analysis*, Bio-protocol 15(9): e5295.

## Pipeline

| Step | Script | Tool | What it does |
|------|--------|------|--------------|
| 1 | `01_qc_raw.sh` | FastQC, MultiQC | Quality report on raw reads |
| 2 | `02_trim.sh` | Trimmomatic | Removes adapters and low-quality bases |
| 3 | `03_qc_trimmed.sh` | FastQC, MultiQC | Confirms trimming worked |
| 4 | `04_reference.sh` | HISAT2 | Downloads genome/annotation, builds index |
| 5 | `05_align.sh` | HISAT2, Samtools | Splice-aware alignment, sorted/indexed BAMs |
| 6 | `06_count.sh` | featureCounts | Gene-level count matrix |
| 7 | `07_deseq2.R` | DESeq2 | Differential expression, PCA, sample clustering |

## Setup

Command-line tools are installed with conda:

```bash
conda env create -f environment.yml
conda activate rnaseq
```

The R step needs R with these packages:

```r
BiocManager::install(c("DESeq2", "pheatmap", "apeglm"))
install.packages(c("ggplot2", "ggrepel"))
```

## Usage

1. Edit `scripts/config.sh`: set `PROJECT_DIR`, `SAMPLES`, and `THREADS`.
2. Put paired FASTQ files in `$PROJECT_DIR/raw_data/`, named `<SAMPLE>_1.fastq.gz` and `<SAMPLE>_2.fastq.gz`.
3. Run the steps in order:

```bash
bash scripts/01_qc_raw.sh
bash scripts/02_trim.sh
bash scripts/03_qc_trimmed.sh
bash scripts/04_reference.sh
bash scripts/05_align.sh
bash scripts/06_count.sh
Rscript scripts/07_deseq2.R
```

Check the QC reports after steps 1 and 3 before continuing.

## Lessons learned

These came up during the original analysis and are worth checking on any new dataset:

- **Confirm the adapter type before trimming.** This library was Nextera-prepped. Trimming with the TruSeq adapter file improved quality scores but left ~48% of reads carrying adapter sequence. FastQC's overrepresented-sequences section identified the real adapter (`CTGTCTCTTATACACATCT`).
- **Trimmomatic can run out of Java memory** on large files with many threads. `config.sh` raises the Java heap limit to 8 GB.
- **Build a plain HISAT2 index.** Adding `--ss`/`--exon` during index building can require hundreds of GB of RAM. Passing known splice sites at alignment time (`--known-splicesite-infile`) is much lighter.
- **Count read pairs, not reads.** For paired-end data, featureCounts needs `-p --countReadPairs`, or each fragment is counted twice.
- **Look at the PCA before trusting DE results.** Outlier samples and high replicate-to-replicate variability can drive the number of significant genes more than the treatment does.
- **ARM64 machines** (e.g., Snapdragon laptops under WSL) need the `aarch64` Miniconda installer. The bioconda tools used here all have ARM64 builds.

## Data

No sequencing data or results are included in this repository. The scripts expect data in the directory set by `PROJECT_DIR`.
