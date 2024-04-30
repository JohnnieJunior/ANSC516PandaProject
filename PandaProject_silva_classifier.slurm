#!/bin/sh -l

#SBATCH --nodes=1                   ##number of requested nodes (a node is a group of CPUs)
#SBATCH -n 20		         ##number of requested CPUs
#SBATCH --time=24:00:00             ##time requested
#SBATCH --job-name PandaProject_qiime_classifier ##name of job
#SBATCH -A highmem                 ##name of the queue you are using. Could be scholar or microbiome if you are on snyder

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

#Retrieve the database

echo "download the database files"

wget https://data.qiime2.org/2023.9/common/silva-138-99-seqs.qza
wget https://data.qiime2.org/2023.9/common/silva-138-99-tax.qza

#echo "finished downloading the database files"

echo "trim the ref seqs"
date +"%d %B %Y %H:%M:%S"

##YOU need to enter YOUR primers in this command. For learnings sake
##use this example below. For your own project, use the primers used
##in your project.

qiime feature-classifier extract-reads \
--i-sequences silva-138-99-seqs.qza \
--p-f-primer CCTACGGGAGGCAGCAG  \
--p-r-primer ATTACCGCGGCTGCT  \
--p-min-length 50  \
--p-max-length 350 \
--p-n-jobs 12 \
--o-reads ref-seqs-v3.qza 

date +"%d %B %Y %H:%M:%S"
echo "Train the classifier"

qiime feature-classifier fit-classifier-naive-bayes \
--i-reference-reads ref-seqs-v3.qza \
--i-reference-taxonomy silva-138-99-tax.qza \
--o-classifier silva-classifier-v3.qza


echo "Copy a practice set of sequences (moving pictures	dataset)"
date +"%d %B %Y %H:%M:%S"

qiime feature-classifier classify-sklearn \
  --i-classifier silva-classifier-v3.qza \
  --i-reads rep-seqs.qza \
  --p-n-jobs -1 \
  --o-classification taxonomy.qza

qiime metadata tabulate \
  --m-input-file taxonomy.qza \
  --o-visualization taxonomy.qzv  ##Convert to .qzv

qiime taxa barplot \
  --i-table table.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file PandaProjectMetadata.txt \
  --o-visualization taxa-bar-plots.qzv

echo "End time"
date +"%d %B %Y %H:%M:%S"

#to run: sbatch PandaProject_silva_classifier.slurm
