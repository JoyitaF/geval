#!/bin/bash

sample=$1

#dir
SAMPLE_DIR=sample
RAW_QC_DIR=raw_qc

#out dir
mkdir -p $RAW_QC_DIR

#files
input1=${SAMPLE_DIR}/${sample}_1.fastq.gz
input2=${SAMPLE_DIR}/${sample}_2.fastq.gz

fastqc -o $RAW_QC_DIR $input1 $input2
