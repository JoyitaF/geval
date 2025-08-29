#!/usr/bin/bash
#SBATCH --time=1:00:00
#SBATCH --ntasks=4
#SBATCH --account=PYS1149
#SBATCH --job-name=CombineGenotype
#SBATCH -e log/%x-%j.err
#SBATCH -o log/%x-%j.out

source activate /users/PYS1149/joyita/pkg/envs/geval0

# ---- Paths ----
REF_DIR=$HOME/Geval/ref
OUTPUT_DIR=$HOME/Geval/vc
SAMPLE_LIST=$HOME/Geval/sample/sample.txt

refgenome=$REF_DIR/hg38.p14.fa
intervals=$REF_DIR/hglft_genome_2e9ec1_76c970.interval_list
combined_gvcf=${OUTPUT_DIR}/cohort.g.vcf
vcf_output=${OUTPUT_DIR}/cohort.vcf

# Build GVCF arguments
GVCF_ARGS=""
while read SAMPLE; do
  GVCF_ARGS+=" -V ${OUTPUT_DIR}/${SAMPLE}.g.vcf"
done < $SAMPLE_LIST

# Combine GVCFs
gatk CombineGVCFs \
  -R $refgenome \
  $GVCF_ARGS \
  -O $combined_gvcf \
  -L $intervals

# Genotype GVCFs
gatk GenotypeGVCFs \
  -R $refgenome \
  -V $combined_gvcf \
  -O $vcf_output \
  -L $intervals



