#!/bin/bash

sample=$1

#dir
POST_ALIGNED_DIR=post_aligned
METRICS_DIR=metrics
REF_DIR=ref

#out dir
mkdir -p $METRICS_DIR

#files
sortedbam=${POST_ALIGNED_DIR}/${sample}_fixed_sorted.bam
refgenome=${REF_DIR}/hg38.p14.fa
interval=${REF_DIR}/hglft_genome_2e9ec1_76c970.interval_list

#out files
yield_metrics=${METRICS_DIR}/${sample}_QualityYieldMetrics.txt
oxoG_metrics=${METRICS_DIR}/${sample}_OxoGMetrics.txt
flagstat_out=${METRICS_DIR}/${sample}_flagstat.txt
idxstats_out=${METRICS_DIR}/${sample}_idxstats.txt
samtools_stats_out=${METRICS_DIR}/${sample}_samtools_stats.txt
alignment_summary=${METRICS_DIR}/${sample}_AlignmentSummary.txt
hs_metrics=${METRICS_DIR}/${sample}_HsMetrics.txt
insert_metrics=${METRICS_DIR}/${sample}_InsertSize.txt
insert_histogram=${METRICS_DIR}/${sample}_InsertSize_histogram.pdf

#metrics
gatk CollectQualityYieldMetrics -I $sortedbam -O $yield_metrics

gatk CollectOxoGMetrics -I $sortedbam -O $oxoG_metrics -R $refgenome

samtools flagstat $sortedbam > $flagstat_out
samtools index $sortedbam
samtools idxstats $sortedbam > $idxstats_out
samtools stats $sortedbam > $samtools_stats_out

gatk CollectAlignmentSummaryMetrics -R $refgenome -I $sortedbam -O $alignment_summary

gatk CollectHsMetrics -R $refgenome -I $sortedbam -O $hs_metrics --BAIT_INTERVALS $interval --TARGET_INTERVALS $interval

gatk CollectInsertSizeMetrics -I $sortedbam -O $insert_metrics -H $insert_histogram -M 0.5

