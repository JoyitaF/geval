#!/usr/bin/bash
#SBATCH --time=1:00:00
#SBATCH --ntasks=4
#SBATCH --account=PYS1149
#SBATCH --job-name=Variant_Filtering
#SBATCH -e log/%x.batch-%j.err
#SBATCH -o log/%x.batch-%j.out

source activate /users/PYS1149/joyita/pkg/envs/geval0

# Directories
REF_DIR=$HOME/Geval/ref
VCF_DIR=$HOME/Geval/vc
OUTPUT_VF_DIR=$HOME/Geval/vf

# Output directory for filtered variants
mkdir -p $OUTPUT_VF_DIR

echo "Running Variant Selection and Filtering for sample: $SAMPLE"

# Define input/output files
input_vcf=$VCF_DIR/${SAMPLE}.vcf
refgenome=$REF_DIR/hg38.p14.fa
intervals=$REF_DIR/hglft_genome_2e9ec1_76c970.interval_list  

# Filter SNPs
sample_snp_filtered_vcf=${OUTPUT_VF_DIR}/${SAMPLE}_SNP_Filtered.vcf
gatk VariantFiltration \
  -R $refgenome \
  -V $sample_snp_vcf \
  -O $sample_snp_filtered_vcf \
  --filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0 || SOR > 3.0" \
  --filter-name "fail" \
  -L $intervals

# Filter INDELs
sample_indel_filtered_vcf=${OUTPUT_VF_DIR}/${SAMPLE}_INDEL_Filtered.vcf
gatk VariantFiltration \
  -R $refgenome \
  -V $sample_indel_vcf \
  -O $sample_indel_filtered_vcf \
  --filter-expression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0" \
  --filter-name "fail" \
  -L $intervals

# Step 5: Select only passed SNPs (exclude filtered)
sample_snp_passed_vcf=${OUTPUT_VF_DIR}/${SAMPLE}_SNP_Passed.vcf
gatk SelectVariants \
  -R $refgenome \
  -V $sample_snp_filtered_vcf \
  -O $sample_snp_passed_vcf \
  --exclude-filtered

# Step 6: Select only passed INDELs (exclude filtered)
sample_indel_passed_vcf=${OUTPUT_VF_DIR}/${SAMPLE}_INDEL_Passed.vcf
gatk SelectVariants \
  -R $refgenome \
  -V $sample_indel_filtered_vcf \
  -O $sample_indel_passed_vcf \
  --exclude-filtered

echo "Variant filtering completed for sample: $SAMPLE"




