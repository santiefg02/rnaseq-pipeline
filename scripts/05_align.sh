#!/usr/bin/env bash
# Step 5: Align trimmed read pairs to the genome (HISAT2), then sort and
# index the alignments (Samtools). SAM output is piped straight into
# sorting so large intermediate files are never written to disk.
set -euo pipefail
source "$(dirname "$0")/config.sh"
cd "$PROJECT_DIR"

mkdir -p aligned
for sample in "${SAMPLES[@]}"; do
  echo "=== Aligning $sample ==="
  hisat2 -p "$THREADS" --dta \
    -x reference/"$INDEX_PREFIX" \
    --known-splicesite-infile reference/splicesites.txt \
    -1 trimmed/${sample}_1_paired.fastq.gz \
    -2 trimmed/${sample}_2_paired.fastq.gz \
    2> aligned/${sample}_align_summary.txt \
    | samtools sort -@ "$THREADS" -o aligned/${sample}.sorted.bam -
  samtools index aligned/${sample}.sorted.bam
  grep "overall alignment rate" aligned/${sample}_align_summary.txt
done
