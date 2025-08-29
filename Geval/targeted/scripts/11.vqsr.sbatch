#!/usr/bin/bash
#SBATCH --time=3:00:00
#SBATCH --ntasks=4
#SBATCH --account=PYS1149
#SBATCH --job-name=VQSR
#SBATCH --array=0-2  # Adjust based on number of samples
#SBATCH -e log/%x-%A_%a.err
#SBATCH -o log/%x-%A_%a.out

source activate /users/PYS1149/joyita/pkg/envs/geval0

# ---- Paths ----
KNOWN_SITES_DIR=$HOME/Geval/known_sites
REF_DIR=$HOME/Geval/ref
OUTPUT_DIR=$HOME/Geval/vf
SAMPLE_LIST=$HOME/Geval/sample/sample.txt  

# Read sample name based on array index
SAMPLE=$(sed -n "$((SLURM_ARRAY_TASK_ID+1))p" $SAMPLE_LIST)

echo "Running VQSR for sample: $SAMPLE"

# Input VCFs
SNP_VCF=${OUTPUT_DIR}/${SAMPLE}_SNP.vcf
INDEL_VCF=${OUTPUT_DIR}/${SAMPLE}_INDEL.vcf

# Resources
refgenome=$REF_DIR/hg38.p14.fa
HAPMAP=$KNOWN_SITES_DIR/hapmap_3.3.hg38.vcf.gz
OMNI=$KNOWN_SITES_DIR/1000G_omni2.5.hg38.vcf.gz
G1000=$KNOWN_SITES_DIR/1000G_phase.snps.high_confidence.hg38.vcf.gz
DBSNP=$KNOWN_SITES_DIR/resources_broad_hg38_v0_Homo_sapiens_assembly38.dbsnp138.vcf
MILLS=$KNOWN_SITES_DIR/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz

# Step 1: Recalibrate SNPs
gatk VariantRecalibrator \
  -R $refgenome \
  -V $SNP_VCF \
  --resource:hapmap,known=false,training=true,truth=true,prior=15.0 $HAPMAP \
  --resource:omni,known=false,training=true,truth=false,prior=12.0 $OMNI \
  --resource:1000G,known=false,training=true,truth=false,prior=10.0 $G1000 \
  --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $DBSNP \
  -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR \
  -mode SNP \
  -O ${OUTPUT_DIR}/${SAMPLE}_SNP_vqsr.recal \
  --tranches-file ${OUTPUT_DIR}/${SAMPLE}_SNP_vqsr.tranches

# Step 2: Recalibrate INDELs
gatk VariantRecalibrator \
  -R $refgenome \
  -V $INDEL_VCF \
  --resource:mills,known=false,training=true,truth=true,prior=12 $MILLS \
  --resource:dbsnp,known=true,training=false,truth=false,prior=2 $DBSNP \
  -an FS -an ReadPosRankSum -an MQRankSum -an QD -an SOR \
  -mode INDEL \
  -O ${OUTPUT_DIR}/${SAMPLE}_INDEL_vqsr.recal \
  --tranches-file ${OUTPUT_DIR}/${SAMPLE}_INDEL_vqsr.tranches

# Step 3: Apply VQSR to SNPs
gatk ApplyVQSR \
  -R $refgenome \
  -V $SNP_VCF \
  -O ${OUTPUT_DIR}/${SAMPLE}_SNP_appliedVQSR.vcf \
  --truth-sensitivity-filter-level 99.0 \
  --tranches-file ${OUTPUT_DIR}/${SAMPLE}_SNP_vqsr.tranches \
  --recal-file ${OUTPUT_DIR}/${SAMPLE}_SNP_vqsr.recal \
  -mode SNP

# Step 4: Apply VQSR to INDELs
gatk ApplyVQSR \
  -R $refgenome \
  -V $INDEL_VCF \
  -O ${OUTPUT_DIR}/${SAMPLE}_INDEL_appliedVQSR.vcf \
  --truth-sensitivity-filter-level 99.0 \
  --tranches-file ${OUTPUT_DIR}/${SAMPLE}_INDEL_vqsr.tranches \
  --recal-file ${OUTPUT_DIR}/${SAMPLE}_INDEL_vqsr.recal \
  -mode INDEL




