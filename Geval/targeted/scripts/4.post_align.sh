#!/bin/bash

sample=$1

#dir
ALIGNED_DIR=aligned
POST_ALIGNED_DIR=post_aligned

#out dir
mkdir -p $POST_ALIGNED_DIR

#files
aligned=${ALIGNED_DIR}/aligned_${sample}.bam
fixed=${POST_ALIGNED_DIR}/${sample}_fixed.bam
sorted=${POST_ALIGNED_DIR}/${sample}_fixed_sorted.bam
marked=${POST_ALIGNED_DIR}/${sample}_fixed_sorted_markdup.bam
metrics=${POST_ALIGNED_DIR}/${sample}_markdup.txt

#fix, sort, mark duplicates
gatk FixMateInformation -I $aligned -O $fixed

gatk SortSam -I $fixed -O $sorted -SO coordinate

gatk MarkDuplicates -I $sorted -O $marked --METRICS_FILE $metrics --REMOVE_DUPLICATES false --ASSUME_SORTED true --CREATE_INDEX true

