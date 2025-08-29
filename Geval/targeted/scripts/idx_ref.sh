#!/bin/bash

sample=$1

REF_DIR=ref

bwa index -a bwtsw ${REF_DIR}/${sample}

samtools faidx ${REF_DIR}/${sample}

gatk CreateSequenceDictionary -R ${REF_DIR}/${sample}

