#!/bin/bash
#SBATCH --job-name=metrics
#SBATCH --ntasks=4
#SBATCH --account=PYS1149
#SBATCH --array=0-7
#SBATCH --output=logs/metrics_%A_%a.out
#SBATCH --error=logs/metrics_%A_%a.err
#SBATCH --time=02:00:00

source activate /users/PYS1149/joyita/pkg/envs/geval0

SAMPLE=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$SAMPLEFILE")

POST_ALIGNED_DIR=post_aligned
METRICS_DIR=metrics
REF_DIR=../ref
INTERVAL_DIR=interval

mkdir -p $METRICS_DIR

echo "Running for sample: $SAMPLE"

# Define input files
sortedbam=${POST_ALIGNED_DIR}/${SAMPLE}_fixed_sorted.bam
refgenome=${REF_DIR}/hg38.p14.fa
interval=${INTERVAL_DIR}/Illumina_Exome_TargetedRegions_v1.2.hg38.interval_list

# Define output files
yield_metrics=${METRICS_DIR}/${SAMPLE}_QualityYieldMetrics.txt
oxoG_metrics=${METRICS_DIR}/${SAMPLE}_OxoGMetrics.txt
flagstat_out=${METRICS_DIR}/${SAMPLE}_flagstat.txt
idxstats_out=${METRICS_DIR}/${SAMPLE}_idxstats.txt
samtools_stats_out=${METRICS_DIR}/${SAMPLE}_samtools_stats.txt
alignment_summary=${METRICS_DIR}/${SAMPLE}_AlignmentSummary.txt
hs_metrics=${METRICS_DIR}/${SAMPLE}_HsMetrics.txt
insert_metrics=${METRICS_DIR}/${SAMPLE}_InsertSize.txt
insert_histogram=${METRICS_DIR}/${SAMPLE}_InsertSize_histogram.pdf

# Run GATK and SAMtools metrics collection
gatk CollectQualityYieldMetrics -I $sortedbam -O $yield_metrics

gatk CollectOxoGMetrics -I $sortedbam -O $oxoG_metrics -R $refgenome

samtools flagstat $sortedbam > $flagstat_out
samtools index $sortedbam
samtools idxstats $sortedbam > $idxstats_out
samtools stats $sortedbam > $samtools_stats_out

gatk CollectAlignmentSummaryMetrics -R $refgenome -I $sortedbam -O $alignment_summary

gatk CollectHsMetrics -R $refgenome -I $sortedbam -O $hs_metrics --BAIT_INTERVALS $interval --TARGET_INTERVALS $interval

gatk CollectInsertSizeMetrics -I $sortedbam -O $insert_metrics -H $insert_histogram -M 0.5
