#!/bin/bash

inputbam=$1
reffa=$2
Xms=$3  # '8g'
ERC=$4  #'GVCF'
outdir=$5  # '.'

mkdir -p $outdir
gatk HaplotypeCaller --java-options "-Xms$Xms" -R $reffa -O $outdir/out_full.g.vcf.gz -I $inputbam -ERC $ERC --max-alternate-alleles 3 --read-filter OverclippedReadFilter

