#!/bin/bash
#SBATCH --job-name=post_align
#SBATCH --ntasks=4
#SBATCH --account=PYS1149
#SBATCH --array=0-7
#SBATCH --output=logs/post_align_%A_%a.out
#SBATCH --error=logs/post_align_%A_%a.err
#SBATCH --time=02:00:00

module load gatk

sample=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$SAMPLEFILE")

ALIGNED_DIR=aligned
POST_ALIGNED_DIR=post_aligned

mkdir -p $POST_ALIGNED_DIR

aligned=${ALIGNED_DIR}/aligned_${sample}.bam
fixed=${POST_ALIGNED_DIR}/${sample}_fixed.bam
sorted=${POST_ALIGNED_DIR}/${sample}_fixed_sorted.bam
marked=${POST_ALIGNED_DIR}/${sample}_fixed_sorted_markdup.bam
metrics=${POST_ALIGNED_DIR}/${sample}_markdup.txt

gatk FixMateInformation -I $aligned -O $fixed
gatk SortSam -I $fixed -O $sorted -SO coordinate
gatk MarkDuplicates -I $sorted -O $marked --METRICS_FILE $metrics --CREATE_INDEX true

