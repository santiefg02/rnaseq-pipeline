#!/usr/bin/env bash
# Step 2: Adapter and quality trimming (Trimmomatic, paired-end)
set -euo pipefail
source "$(dirname "$0")/config.sh"
cd "$PROJECT_DIR"

ADAPTER_FILE=$(ls "$CONDA_PREFIX"/share/trimmomatic*/adapters/"$ADAPTERS" 2>/dev/null | head -n 1)
if [[ -z "$ADAPTER_FILE" ]]; then
  echo "ERROR: adapter file $ADAPTERS not found. Is the conda environment active?" >&2
  exit 1
fi
echo "Using adapters: $ADAPTER_FILE"

mkdir -p trimmed
for sample in "${SAMPLES[@]}"; do
  echo "=== Trimming $sample ==="
  trimmomatic PE -threads "$THREADS" -phred33 \
    raw_data/${sample}_1.fastq.gz raw_data/${sample}_2.fastq.gz \
    trimmed/${sample}_1_paired.fastq.gz trimmed/${sample}_1_unpaired.fastq.gz \
    trimmed/${sample}_2_paired.fastq.gz trimmed/${sample}_2_unpaired.fastq.gz \
    ILLUMINACLIP:"$ADAPTER_FILE":2:30:10:2:True \
    SLIDINGWINDOW:4:20 MINLEN:36
done
