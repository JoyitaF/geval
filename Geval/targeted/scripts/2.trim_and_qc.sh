#!/bin/bash

sample=$1

#dir
SAMPLE_DIR=sample
TRIMMED_DIR=trimmed
TRIMMED_QC_DIR=trimmed_qc

#out dir
mkdir -p $TRIMMED_DIR
mkdir -p $TRIMMED_QC_DIR

#files
input1=${SAMPLE_DIR}/${sample}_1.fastq.gz
input2=${SAMPLE_DIR}/${sample}_2.fastq.gz

outp1=${TRIMMED_DIR}/trimmed_${sample}_p1.fastq.gz
outu1=${TRIMMED_DIR}/trimmed_${sample}_u1.fastq.gz
outp2=${TRIMMED_DIR}/trimmed_${sample}_p2.fastq.gz
outu2=${TRIMMED_DIR}/trimmed_${sample}_u2.fastq.gz

#trimmomatic path
adapter="/home/joyitaf/miniconda3/envs/geval0/share/trimmomatic-0.39-2/adapters/TruSeq3-PE-2.fa"

#trim opt
clip="2:30:10"
trail=20
minlen=50
slide="5:20"
headcrop=20
leading=20

#trim
trimmomatic PE -threads 1 $input1 $input2 $outp1 $outu1 $outp2 $outu2 ILLUMINACLIP:$adapter:$clip TRAILING:$trail MINLEN:$minlen SLIDINGWINDOW:$slide HEADCROP:$headcrop LEADING:$leading

#qc
fastqc -o $TRIMMED_QC_DIR $outp1 $outp2
