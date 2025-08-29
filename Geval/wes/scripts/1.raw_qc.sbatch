#!/bin/bash
#SBATCH --job-name=raw_qc
#SBATCH --ntasks=4
#SBATCH --account=PYS1149
#SBATCH --array=0-7
#SBATCH --output=logs/raw_qc_%A_%a.out
#SBATCH --error=logs/raw_qc_%A_%a.err
#SBATCH --time=02:00:00

# Load modules
module load fastqc

# Get sample name from array
sample=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$SAMPLEFILE")

# Directories
RAW_QC_DIR=raw_qc
SAMPLE_DIR=/fs/scratch/PYS1149/joyita/sample

mkdir -p $RAW_QC_DIR

# Input files
input1=${SAMPLE_DIR}/${sample}_1.fastq.gz
input2=${SAMPLE_DIR}/${sample}_2.fastq.gz

# Run FastQC
fastqc -t 2 -o $RAW_QC_DIR $input1 $input2
