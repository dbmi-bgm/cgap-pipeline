#!/bin/bash

input_vcf=$1
ref_fa=$2
outprefix=$3
indel_vcf=$4
max_gaussians=$5 # default 8
xmx=$6

gatk SelectVariants -Xmx${xmx} -R $ref_fa \
-V $input_vcf \
-O $outprefix.indelmixed.vcf.gz \
--select-type-to-include INDEL \
--select-type-to-include MIXED ;

gatk VariantRecalibrator -Xmx${xmx} \
-R $ref_fa \
-V $outprefix.indelmixed.vcf.gz \
--resource:mills,known=true,training=true,truth=true,prior=12.0 $indel_vcf \
-an QD -an ReadPosRankSum -an FS \
-mode INDEL \
-O $outprefix.indelmixed.recal \
--max-gaussians $max_gaussians \
--tranches-file $outprefix.indelmixed.tranches \
--rscript-file $outprefix.indelmixed.recal.plots.R ;

gatk ApplyVQSR -Xmx${xmx} \
-R $ref_fa \
-V $outprefix.indelmixed.vcf.gz \
--ts-filter-level 99.0 \
-mode INDEL \
--tranches-file $outprefix.indelmixed.tranches \
--recal-file $outprefix.indelmixed.recal \
-O $outprefix.indelmixed.vqsr.vcf.gz ;
