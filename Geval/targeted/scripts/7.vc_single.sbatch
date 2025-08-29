#!/usr/bin/bash
#SBATCH --time=1:00:00
#SBATCH --ntasks=4
#SBATCH --account=PYS1149
#SBATCH --job-name=HaplotypeCaller_Single
#SBATCH -e log/%x.batch-%j.err
#SBATCH -o log/%x.batch-%j.out

source activate /users/PYS1149/joyita/pkg/envs/geval0

# Dir
BQSR_DIR=$HOME/Geval/bqsr
REF_DIR=$HOME/Geval/ref
KNOWN_SITES_DIR=$HOME/Geval/known_sites
OUTPUT_DIR=$HOME/Geval/vc
OUTPUT_VF_DIR=$HOME/Geval/vf


# Output dir
mkdir -p $OUTPUT_DIR
mkdir -p $OUTPUT_VF_DIR

echo "Running for sample: $SAMPLE"

# Copy required files to tmp
mkdir -p $TMPDIR/bqsr $TMPDIR/ref

cp ${BQSR_DIR}/* $TMPDIR/bqsr/
cp ${REF_DIR}/* $TMPDIR/ref/

# Define input/output files (inside TMP)
input_bam=$TMPDIR/bqsr/${SAMPLE}_fixed_sorted_markdup_applyBQSR.bam
output_vcf=${OUTPUT_DIR}/${SAMPLE}.vcf
refgenome=$TMPDIR/ref/hg38.p14.fa
intervals=$TMPDIR/ref/hglft_genome_2e9ec1_76c970.interval_list

# Run GATK HaplotypeCaller
gatk HaplotypeCaller \
  -I $input_bam \
  -O $output_vcf \
  -R $refgenome \
  -L $intervals

# Select SNPs
sample_snp_vcf=${OUTPUT_VF_DIR}/${SAMPLE}_SNP.vcf
gatk SelectVariants \
  -R $refgenome \
  -V $output_vcf \
  -O $sample_snp_vcf \
  --select-type SNP

# Select INDELs
sample_indel_vcf=${OUTPUT_VF_DIR}/${SAMPLE}_INDEL.vcf
gatk SelectVariants \
  -R $refgenome \
  -V $output_vcf \
  -O $sample_indel_vcf \
  --select-type INDEL

