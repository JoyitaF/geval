#!/bin/bash

sample=$1

#dir
POST_ALIGNED_DIR=post_aligned
KNOWN_SITES_DIR=known_sites
BQSR_DIR=bqsr
REF_DIR=ref

#outdir
mkdir -p $BQSR_DIR

#files
input_bam=${POST_ALIGNED_DIR}/${sample}_fixed_sorted_markdup.bam
recal_table=${BQSR_DIR}/${sample}_baseRecal.table
output_bam=${BQSR_DIR}/${sample}_fixed_sorted_markdup_applyBQSR.bam
refgenome=${REF_DIR}/hg38.p14.fa
intervals=${REF_DIR}/hglft_genome_2e9ec1_76c970.interval_list
dbsnp=${KNOWN_SITES_DIR}/resources_broad_hg38_v0_Homo_sapiens_assembly38.dbsnp138.vcf
known_indels=${KNOWN_SITES_DIR}/resources_broad_hg38_v0_Homo_sapiens_assembly38.known_indels.vcf.gz

#recal table
gatk BaseRecalibrator \
    -I $input_bam \
    -O $recal_table \
    -R $refgenome \
    -L $intervals \
    --known-sites $dbsnp \
    --known-sites $known_indels

#apply BQSR
gatk ApplyBQSR \
    -I $input_bam \
    -O $output_bam \
    -R $refgenome \
    -bqsr $recal_table

