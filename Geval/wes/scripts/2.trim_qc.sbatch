#!/bin/bash
#SBATCH --job-name=trim_qc
#SBATCH --ntasks=4
#SBATCH --account=PYS1149
#SBATCH --array=0-7
#SBATCH --output=logs/trim_qc_%A_%a.out
#SBATCH --error=logs/trim_qc_%A_%a.err
#SBATCH --time=02:00:00

module load fastqc
module load java
module load trimmomatic/0.38

sample=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$SAMPLEFILE")

SAMPLE_DIR=/fs/scratch/PYS1149/joyita/sample
TRIMMED_DIR=trimmed
TRIMMED_QC_DIR=trimmed_qc

mkdir -p "$TRIMMED_DIR" "$TRIMMED_QC_DIR"

input1="${SAMPLE_DIR}/${sample}_1.fastq.gz"
input2="${SAMPLE_DIR}/${sample}_2.fastq.gz"

outp1="${TRIMMED_DIR}/trimmed_${sample}_p1.fastq.gz"
outu1="${TRIMMED_DIR}/trimmed_${sample}_u1.fastq.gz"
outp2="${TRIMMED_DIR}/trimmed_${sample}_p2.fastq.gz"
outu2="${TRIMMED_DIR}/trimmed_${sample}_u2.fastq.gz"

adapter="/home/joyitaf/miniconda3/envs/geval0/share/trimmomatic-0.39-2/adapters/TruSeq3-PE-2.fa"

java -jar "$TRIMMOMATIC" PE \
  -threads 2 \
  "$input1" "$input2" \
  "$outp1" "$outu1" "$outp2" "$outu2" \
  ILLUMINACLIP:"$adapter":2:30:10 \
  TRAILING:20 \
  MINLEN:50 \
  SLIDINGWINDOW:5:20 \
  HEADCROP:20 \
  LEADING:20

fastqc -t 2 -o "$TRIMMED_QC_DIR" "$outp1" "$outp2"
