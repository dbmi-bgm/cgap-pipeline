#!/bin/bash

inputbam=$1
reffa=$2
ERC=$3  #'GVCF' | 'BP_RESOLUTION'
Xms=$4  # '8g'
outdir=$5  # '.'

mkdir -p $outdir
gatk HaplotypeCaller --java-options "-Xms$Xms" -R $reffa -O $outdir/out_full.g.vcf.gz -I $inputbam -ERC $ERC --max-alternate-alleles 3 --read-filter OverclippedReadFilter

