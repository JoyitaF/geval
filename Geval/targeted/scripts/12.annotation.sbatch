#!/usr/bin/bash
#SBATCH --time=2:00:00
#SBATCH --ntasks=4
#SBATCH --account=PYS1149
#SBATCH --job-name=Annotation
#SBATCH --array=0-2  # Adjust based on the number of samples
#SBATCH -e log/%x-%A_%a.err
#SBATCH -o log/%x-%A_%a.out

source activate /users/PYS1149/joyita/pkg/envs/geval0

# ---- Paths ----
SAMPLE_LIST=$HOME/Geval/sample/sample.txt
SAMPLE=$(sed -n "$((SLURM_ARRAY_TASK_ID+1))p" $SAMPLE_LIST)
VF_DIR=$HOME/Geval/vf 
OUTPUT_DIR=$HOME/Geval/annotation
ANNOVAR_DIR=$HOME/annovar
HDB_DIR=${ANNOVAR_DIR}/humandb

# Create necessary output directory
mkdir -p $OUTPUT_DIR

echo "Running annotation for sample: $SAMPLE"

# Step 1: VCF to avinput conversion
IN_VCF=$VF_DIR/${SAMPLE}_SNP.vcf
OUT_AVINPUT=$OUTPUT_DIR/${SAMPLE}_hg38.avinput

$ANNOVAR_DIR/convert2annovar.pl -format vcf4 $IN_VCF -outfile $OUT_AVINPUT -allsample -includeinfo

# Step 2: Generate multianno.csv using avinput
IN_AVINPUT=$OUTPUT_DIR/${SAMPLE}_hg38.avinput
OUT_CSV=$OUTPUT_DIR/${SAMPLE}

ANNO_DB="avsnp150,clinvar_20221231,cosmic70,dbnsfp42c,dbscsnv11,ensGene,exac03,gnomad211_exome,gnomad312_genome,intervar_20180118,knownGene,refGene"
OPER="f,f,f,f,f,g,f,f,f,f,g,g"

$ANNOVAR_DIR/table_annovar.pl $IN_AVINPUT $HDB_DIR -buildver hg38 -out $OUT_CSV \
    -remove -protocol $ANNO_DB -operation $OPER -nastring . -csvout -polish





