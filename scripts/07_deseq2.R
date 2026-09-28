# Step 7: Differential expression with DESeq2, plus QC plots
#
# Input:  counts/gene_counts.txt from featureCounts (step 6)
# Output: results/ folder with DE tables (CSV) and QC plots (PNG)
#
# Required R packages:
#   BiocManager::install(c("DESeq2", "pheatmap", "apeglm"))
#   install.packages(c("ggplot2", "ggrepel"))

library(DESeq2)
library(ggplot2)
library(pheatmap)

# ---- Settings: edit for your setup ----
project_dir <- "~/rnaseq_project"   # on Windows, use forward slashes, e.g. "C:/Users/you/rnaseq_project"
min_total_count <- 10               # drop genes with fewer reads than this across all samples
alpha <- 0.05                       # adjusted p-value cutoff

# Comparisons to run: c(numerator, denominator).
# Positive log2FoldChange = higher in the numerator group.
contrasts <- list(
  F_vs_P = c("F", "P"),
  C_vs_D = c("C", "D")
)

# ---- Load counts ----
counts_raw <- read.table(file.path(project_dir, "counts/gene_counts.txt"),
                         header = TRUE, sep = "\t", comment.char = "#",
                         row.names = 1, check.names = FALSE)

# featureCounts adds Chr/Start/End/Strand/Length before the sample columns
counts <- counts_raw[, 6:ncol(counts_raw)]
colnames(counts) <- sub("\\.sorted\\.bam$", "", basename(colnames(counts)))

# ---- Sample metadata ----
# Condition is taken from the first letter of each sample ID (C01 -> C).
# If your naming differs, build this table by hand instead.
coldata <- data.frame(
  row.names = colnames(counts),
  condition = factor(substr(colnames(counts), 1, 1))
)
stopifnot(all(rownames(coldata) == colnames(counts)))
print(table(coldata$condition))

# ---- Run DESeq2 ----
dds <- DESeqDataSetFromMatrix(countData = counts, colData = coldata,
                              design = ~ condition)
dds <- dds[rowSums(counts(dds)) >= min_total_count, ]
dds <- DESeq(dds)

out_dir <- file.path(project_dir, "results")
dir.create(out_dir, showWarnings = FALSE)

for (name in names(contrasts)) {
  groups <- contrasts[[name]]
  res <- results(dds, contrast = c("condition", groups[1], groups[2]), alpha = alpha)
  res <- res[order(res$padj), ]

  cat("\n=====", name, "=====\n")
  summary(res, alpha = alpha)

  write.csv(as.data.frame(res),
            file.path(out_dir, paste0("DE_", name, "_all.csv")))
  write.csv(as.data.frame(subset(res, padj < alpha)),
            file.path(out_dir, paste0("DE_", name, "_significant.csv")))
}

# ---- QC plots ----
vsd <- vst(dds, blind = TRUE)

# PCA with sample labels, to check that replicates cluster by condition
pca <- plotPCA(vsd, intgroup = "condition", returnData = TRUE)
pct <- round(100 * attr(pca, "percentVar"))
p <- ggplot(pca, aes(PC1, PC2, color = condition, label = name)) +
  geom_point(size = 3) +
  geom_text(vjust = -1, size = 3, show.legend = FALSE) +
  xlab(paste0("PC1: ", pct[1], "% variance")) +
  ylab(paste0("PC2: ", pct[2], "% variance")) +
  coord_fixed() +
  theme_bw()
ggsave(file.path(out_dir, "PCA.png"), p, width = 7, height = 5, dpi = 300)

# Sample-to-sample distance heatmap
d <- dist(t(assay(vsd)))
png(file.path(out_dir, "sample_distances.png"), width = 7, height = 6, units = "in", res = 300)
pheatmap(as.matrix(d), clustering_distance_rows = d, clustering_distance_cols = d)
dev.off()

cat("\nDone. Results written to", out_dir, "\n")
