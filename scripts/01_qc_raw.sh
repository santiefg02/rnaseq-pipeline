#!/usr/bin/env bash
# Step 1: Quality control on raw reads (FastQC + MultiQC summary)
set -euo pipefail
source "$(dirname "$0")/config.sh"
cd "$PROJECT_DIR"

mkdir -p fastqc_raw
fastqc -t "$THREADS" -o fastqc_raw raw_data/*.fastq.gz
multiqc fastqc_raw -o fastqc_raw -f

echo "Done. Open fastqc_raw/multiqc_report.html"
