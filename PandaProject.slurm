#!/bin/sh

#SBATCH --nodes=1
#SBATCH -n 12
#SBATCH --time=12:00:00
#SBATCH --job-name PandaProject
#SBATCH -A microbiome
#########################################################################

echo "Start time"
date +"%d %B %Y %H:%M:%S"

#step 1, cd into the proper directory. This directory must already exist

cd $RCAC_SCRATCH
cd PandaProject

pwd

#step 2, Load Modules

echo "loading bioinfo"
module load bioinfo

echo "loading qiime2-2023.9"
module load Qiime/2-2023.9

#step 3, Run the code you want

echo "initiating qiime2 pipeline"

qiime tools import \
  --type 'SampleData[SequencesWithQuality]' \
  --input-path PandaProjectManifest.txt \
  --output-path single-end-demux.qza \
  --input-format SingleEndFastqManifestPhred33V2

qiime demux summarize \
  --i-data single-end-demux.qza \
  --o-visualization single-end-demux.qzv

qiime dada2 denoise-single \
  --i-demultiplexed-seqs single-end-demux.qza \
  --p-trim-left 25 \
  --p-trunc-len 180 \
  --o-representative-sequences rep-seqs-dada2.qza \
  --o-table table-dada2.qza \
  --o-denoising-stats stats-dada2.qza

qiime metadata tabulate \
  --m-input-file stats-dada2.qza \
  --o-visualization stats-dada2.qzv

mv rep-seqs-dada2.qza rep-seqs.qza
mv table-dada2.qza table.qza

qiime feature-table summarize \
  --i-table table.qza \
  --o-visualization table.qzv \
  --m-sample-metadata-file PandaProjectMetadata.txt

qiime feature-table tabulate-seqs \
  --i-data rep-seqs.qza \
  --o-visualization rep-seqs.qzv

qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs.qza \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza

qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table table.qza \
  --p-sampling-depth 431 \
  --m-metadata-file PandaProjectMetadata.txt \
  --output-dir core-metrics-results

qiime diversity alpha-rarefaction \
  --i-table table.qza \
  --i-phylogeny rooted-tree.qza \
  --p-max-depth 1000 \
  --m-metadata-file PandaProjectMetadata.txt \
  --o-visualization alpha-rarefaction.qzv

#StatisticalTesting

qiime diversity alpha \
--i-table table.qza \
--p-metric chao1 \
--o-alpha-diversity core-metrics-results/chao1_vector.qza

qiime diversity alpha-group-significance \
--i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
--m-metadata-file PandaProjectMetadata.txt \
--o-visualization core-metrics-results/faith-pd-group-significance.qzv

qiime diversity alpha-group-significance \
--i-alpha-diversity core-metrics-results/evenness_vector.qza \
--m-metadata-file PandaProjectMetadata.txt \
--o-visualization core-metrics-results/evenness-group-significance.qzv

qiime diversity alpha-group-significance \
--i-alpha-diversity core-metrics-results/shannon_vector.qza \
--m-metadata-file PandaProjectMetadata.txt \
--o-visualization core-metrics-results/shannon-group-significance.qzv

qiime diversity alpha-group-significance \
--i-alpha-diversity core-metrics-results/observed_features_vector.qza \
--m-metadata-file PandaProjectMetadata.txt \
--o-visualization core-metrics-results/observed_features-group-significance.qzv

qiime diversity alpha-group-significance \
--i-alpha-diversity core-metrics-results/chao1_vector.qza \
--m-metadata-file PandaProjectMetadata.txt \
--o-visualization core-metrics-results/chao1-group-significance.qzv

qiime diversity alpha-correlation \
--i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
--m-metadata-file PandaProjectMetadata.txt \
--o-visualization core-metrics-results/faith-pd-correlation.qzv

qiime diversity alpha-correlation \
--i-alpha-diversity core-metrics-results/evenness_vector.qza \
--m-metadata-file PandaProjectMetadata.txt \
--o-visualization core-metrics-results/evenness-correlation.qzv

qiime diversity alpha-correlation \
--i-alpha-diversity core-metrics-results/shannon_vector.qza \
--m-metadata-file PandaProjectMetadata.txt \
--o-visualization core-metrics-results/shannon-correlation.qzv

qiime diversity alpha-correlation \
--i-alpha-diversity core-metrics-results/observed_features_vector.qza \
--m-metadata-file PandaProjectMetadata.txt \
--o-visualization core-metrics-results/observed_features-correlation.qzv

qiime diversity alpha-correlation \
--i-alpha-diversity core-metrics-results/chao1_vector.qza \
--m-metadata-file PandaProjectMetadata.txt \
--o-visualization core-metrics-results/chao1-correlation.qzv

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file PandaProjectMetadata.txt \
  --m-metadata-column Season \
  --o-visualization core-metrics-results/unweighted-unifrac-Season-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file PandaProjectMetadata.txt \
  --m-metadata-column Age \
  --o-visualization core-metrics-results/unweighted-unifrac-Age-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file PandaProjectMetadata.txt \
  --m-metadata-column Season \
  --o-visualization core-metrics-results/weighted_unifrac-Season-Significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file PandaProjectMetadata.txt \
  --m-metadata-column Age \
  --o-visualization core-metrics-results/weighted_unifrac-Age-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/bray_curtis_distance_matrix.qza \
  --m-metadata-file PandaProjectMetadata.txt \
  --m-metadata-column Season \
  --o-visualization core-metrics-results/bray_curtis_pcoa_results-Season-Significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/bray_curtis_distance_matrix.qza \
  --m-metadata-file PandaProjectMetadata.txt \
  --m-metadata-column Age \
  --o-visualization core-metrics-results/bray_curtis_pcoa_results-Age-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/jaccard_distance_matrix.qza \
  --m-metadata-file PandaProjectMetadata.txt \
  --m-metadata-column Season \
  --o-visualization core-metrics-results/jaccard_distance-Season-Significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/jaccard_distance_matrix.qza \
  --m-metadata-file PandaProjectMetadata.txt \
  --m-metadata-column Age \
  --o-visualization core-metrics-results/jaccard_distance-Age-significance.qzv \
  --p-pairwise

echo "End time"
date +"%d %B %Y %H:%M:%S"

#to run: sbatch PandaProject.slurm
