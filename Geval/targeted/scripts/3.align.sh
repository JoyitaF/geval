#!/bin/bash

sample=$1

#dir
TRIMMED_DIR=trimmed
ALIGNED_DIR=aligned
REF_DIR=ref

#out dir
mkdir -p $ALIGNED_DIR

#files
trimmedp1=${TRIMMED_DIR}/trimmed_${sample}_p1.fastq.gz
trimmedp2=${TRIMMED_DIR}/trimmed_${sample}_p2.fastq.gz
refgenome=${REF_DIR}/hg38.p14.fa
outbam=${ALIGNED_DIR}/aligned_${sample}.bam

#align
bwa mem -R "@RG\tID:${sample}\tPL:ILLUMINA\tLB:1\tSM:${sample}" $refgenome -t 2 -M $trimmedp1 $trimmedp2 | \
samtools view -Sb - > $outbam

