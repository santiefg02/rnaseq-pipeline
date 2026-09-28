#!/usr/bin/env bash
# Step 3: Quality control on trimmed reads, to confirm adapters were removed
set -euo pipefail
source "$(dirname "$0")/config.sh"
cd "$PROJECT_DIR"

mkdir -p fastqc_trimmed
fastqc -t "$THREADS" -o fastqc_trimmed trimmed/*_paired.fastq.gz
multiqc fastqc_trimmed -o fastqc_trimmed -f

echo "Done. Check Adapter Content in fastqc_trimmed/multiqc_report.html"
