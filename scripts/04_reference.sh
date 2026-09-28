#!/usr/bin/env bash
# Step 4: Download the reference genome + annotation, build the HISAT2 index,
# and extract known splice sites from the annotation
set -euo pipefail
source "$(dirname "$0")/config.sh"
mkdir -p "$PROJECT_DIR/reference"
cd "$PROJECT_DIR/reference"

BASE="https://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}"
[[ -f "$GENOME_FA" ]] || { wget "$BASE/fasta/gallus_gallus/dna/${GENOME_FA}.gz"; gunzip "${GENOME_FA}.gz"; }
[[ -f "$GTF" ]]       || { wget "$BASE/gtf/gallus_gallus/${GTF}.gz";           gunzip "${GTF}.gz"; }

# Plain index (no --ss/--exon): those options can need hundreds of GB of RAM.
# Splice sites are supplied separately at alignment time instead.
hisat2-build -p "$THREADS" "$GENOME_FA" "$INDEX_PREFIX"
hisat2_extract_splice_sites.py "$GTF" > splicesites.txt

echo "Index built. Splice sites: $(wc -l < splicesites.txt)"
