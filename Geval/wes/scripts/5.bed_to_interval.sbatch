#!/bin/bash
#SBATCH --job-name=bed_to_interval
#SBATCH --ntasks=4
#SBATCH --account=PYS1149
#SBATCH --output=logs/bed_to_interval_%A_%a.out
#SBATCH --error=logs/bed_to_interval_%A_%a.err
#SBATCH --time=02:00:00

BED_DIR=bed
INTERVAL_DIR=interval

mkdir -p $BED_DIR $INTERVAL_DIR

illumina_exome="Illumina_Exome_TargetedRegions_v1.2.hg38.bed"
url="https://support.illumina.com/content/dam/illumina-support/documents/downloads/productfiles/trusight/hg38/${illumina_exome}"

curl -C - -o "${BED_DIR}/${illumina_exome}" "$url"

module load gatk

illumina_exome_bed="${BED_DIR}/Illumina_Exome_TargetedRegions_v1.2.hg38.bed"
interval_list="$INTERVAL_DIR/Illumina_Exome_TargetedRegions_v1.2.hg38.interval_list"
hg38_dict="../ref/hg38.p14.dict"   

gatk BedToIntervalList \
    -I $illumina_exome_bed \
    -O $interval_list \
    -SD $hg38_dict

