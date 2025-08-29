#!/usr/bin/bash
#SBATCH --time=2:00:00
#SBATCH --ntasks=4
#SBATCH --account=PYS1149
#SBATCH --job-name=BaseRecalibrator_Single
#SBATCH -e log/%x.batch-%j.err
#SBATCH -o log/%x.batch-%j.out

source activate /users/PYS1149/joyita/pkg/envs/geval0

# Dir
POST_ALIGNED_DIR=$HOME/Geval/post_aligned
KNOWN_SITES_DIR=$HOME/Geval/known_sites
BQSR_DIR=$HOME/Geval/bqsr
REF_DIR=$HOME/Geval/ref

# Output dir
mkdir -p $BQSR_DIR

echo "Running for sample: $SAMPLE"

# Define input/output files
input_bam=${POST_ALIGNED_DIR}/${SAMPLE}_fixed_sorted_markdup.bam
recal_table=${BQSR_DIR}/${SAMPLE}_baseRecal.table
output_bam=${BQSR_DIR}/${SAMPLE}_fixed_sorted_markdup_applyBQSR.bam
refgenome=${REF_DIR}/hg38.p14.fa
intervals=${REF_DIR}/hglft_genome_2e9ec1_76c970.interval_list
dbsnp=${KNOWN_SITES_DIR}/resources_broad_hg38_v0_Homo_sapiens_assembly38.dbsnp138.vcf
known_indels=${KNOWN_SITES_DIR}/resources_broad_hg38_v0_Homo_sapiens_assembly38.known_indels.vcf.gz

# Run GATK BaseRecalibrator
gatk BaseRecalibrator \
    -I $input_bam \
    -O $recal_table \
    -R $refgenome \
    -L $intervals \
    --known-sites $dbsnp \
    --known-sites $known_indels

# Run GATK ApplyBQSR
gatk ApplyBQSR \
    -I $input_bam \
    -O $output_bam \
    -R $refgenome \
    -bqsr $recal_table



