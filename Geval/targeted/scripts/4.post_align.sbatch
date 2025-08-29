#!/usr/bin/bash
#SBATCH --time=2:00:00
#SBATCH --ntasks=4
#SBATCH --account=PYS1149
#SBATCH --job-name=Post_Align
#SBATCH -e log/%x.batch-%j.err
#SBATCH -o log/%x.batch-%j.out

source activate /users/PYS1149/joyita/pkg/envs/geval0

# Dir
ALIGNED_DIR=$HOME/Geval/aligned
POST_ALIGNED_DIR=$HOME/Geval/post_aligned

# Output dir
mkdir -p $POST_ALIGNED_DIR

echo "Running for sample: $SAMPLE"

# Define files
aligned=${ALIGNED_DIR}/aligned_${SAMPLE}.bam
fixed=${POST_ALIGNED_DIR}/${SAMPLE}_fixed.bam
sorted=${POST_ALIGNED_DIR}/${SAMPLE}_fixed_sorted.bam
marked=${POST_ALIGNED_DIR}/${SAMPLE}_fixed_sorted_markdup.bam
metrics=${POST_ALIGNED_DIR}/${SAMPLE}_markdup.txt

# Fix, sort, and mark duplicates
gatk FixMateInformation -I $aligned -O $fixed

gatk SortSam -I $fixed -O $sorted -SO coordinate

gatk MarkDuplicates -I $sorted -O $marked --METRICS_FILE $metrics --REMOVE_DUPLICATES false --ASSUME_SORTED true --CREATE_INDEX true



