#!/usr/bin/bash
#SBATCH --time=00:30:00
#SBATCH --ntasks=4
#SBATCH --account=PYS1149
#SBATCH --job-name=MetricsCollection_Single
#SBATCH -e log/%x.batch-%j.err
#SBATCH -o log/%x.batch-%j.out

source activate /users/PYS1149/joyita/pkg/envs/geval0

# Dir
POST_ALIGNED_DIR=$HOME/Geval/post_aligned
METRICS_DIR=$HOME/Geval/metrics
REF_DIR=$HOME/Geval/ref

# Output dir
mkdir -p $METRICS_DIR

echo "Running for sample: $SAMPLE"

# Define input files
sortedbam=${POST_ALIGNED_DIR}/${SAMPLE}_fixed_sorted.bam
refgenome=${REF_DIR}/hg38.p14.fa
interval=${REF_DIR}/hglft_genome_2e9ec1_76c970.interval_list

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




