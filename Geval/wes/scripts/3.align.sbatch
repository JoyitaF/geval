#!/bin/bash
#SBATCH --job-name=align
#SBATCH --ntasks=4
#SBATCH --account=PYS1149
#SBATCH --array=0-7
#SBATCH --output=logs/align_%A_%a.out
#SBATCH --error=logs/align_qc_%A_%a.err
#SBATCH --time=04:00:00

module load bwa samtools

sample=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$SAMPLEFILE")

TRIMMED_DIR=trimmed
ALIGNED_DIR=aligned
REF_DIR=/users/PYS1149/joyita/Geval/ref

mkdir -p $ALIGNED_DIR

trimmedp1=${TRIMMED_DIR}/trimmed_${sample}_p1.fastq.gz
trimmedp2=${TRIMMED_DIR}/trimmed_${sample}_p2.fastq.gz
refgenome=${REF_DIR}/hg38.p14.fa
outbam=${ALIGNED_DIR}/aligned_${sample}.bam

bwa mem -R "@RG\tID:${sample}\tPL:ILLUMINA\tLB:1\tSM:${sample}" -t 4 $refgenome $trimmedp1 $trimmedp2 |
  samtools view -Sb - > $outbam

