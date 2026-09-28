#!/usr/bin/env bash
# Step 6: Count read pairs per gene (featureCounts) into one matrix
set -euo pipefail
source "$(dirname "$0")/config.sh"
cd "$PROJECT_DIR"

mkdir -p counts
BAMS=()
for sample in "${SAMPLES[@]}"; do BAMS+=("aligned/${sample}.sorted.bam"); done

# -p --countReadPairs counts each fragment once instead of each mate
featureCounts -T "$THREADS" -p --countReadPairs \
  -a reference/"$GTF" \
  -o counts/gene_counts.txt \
  "${BAMS[@]}"

cat counts/gene_counts.txt.summary
