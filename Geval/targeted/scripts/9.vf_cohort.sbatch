#!/usr/bin/bash
#SBATCH --time=3:00:00
#SBATCH --ntasks=4
#SBATCH --account=PYS1149
#SBATCH --job-name=HaploCohort
#SBATCH --array=0-2  # Adjust based on number of samples
#SBATCH -e log/%x-%A_%a.err
#SBATCH -o log/%x-%A_%a.out

source activate /users/PYS1149/joyita/pkg/envs/geval0

# ---- Paths ----
BQSR_DIR=$HOME/Geval/bqsr
REF_DIR=$HOME/Geval/ref
OUTPUT_DIR=$HOME/Geval/vc
SAMPLE_LIST=$HOME/Geval/sample/sample.txt

# Read sample name based on array index
SAMPLE=$(sed -n "$((SLURM_ARRAY_TASK_ID+1))p" $SAMPLE_LIST)

echo "Running HaplotypeCaller for sample: $SAMPLE"

mkdir -p $TMPDIR/bqsr $TMPDIR/ref $OUTPUT_DIR

cp ${BQSR_DIR}/* $TMPDIR/bqsr/
cp ${REF_DIR}/* $TMPDIR/ref/

input_bam=$TMPDIR/bqsr/${SAMPLE}_fixed_sorted_markdup_applyBQSR.bam
output_gvcf=${OUTPUT_DIR}/${SAMPLE}.g.vcf
refgenome=$TMPDIR/ref/hg38.p14.fa
intervals=$TMPDIR/ref/hglft_genome_2e9ec1_76c970.interval_list

# HaplotypeCaller in GVCF mode
gatk HaplotypeCaller \
  -I $input_bam \
  -O $output_gvcf \
  -R $refgenome \
  -L $intervals \
  -ERC GVCF



