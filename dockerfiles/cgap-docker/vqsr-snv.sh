#!/bin/bash

input_vcf=$1
ref_fa=$2
outprefix=$3
hapmap_vcf=$4
omni_vcf=$5
phase1_vcf=$6
dbsnp_vcf=$7
xmx=$8

gatk SelectVariants \
--java-options -Xmx${xmx} \
-R $ref_fa \
-V $input_vcf \
-O $outprefix.mnv.vcf.gz \
--select-type-to-include SNP \
--select-type-to-include MNP;

gatk VariantRecalibrator \
--java-options -Xmx${xmx} \
-R $ref_fa \
--resource:hapmap,known=false,training=true,truth=true,prior=15.0 $hapmap_vcf \
--resource:omni,known=false,training=true,truth=true,prior=12.0 $omni_vcf \
--resource:1000G,known=false,training=true,truth=false,prior=10.0 $phase1_vcf \
--resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $dbsnp_vcf \
-an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR \
-mode SNP \
-V $outprefix.mnv.vcf.gz \
-O $outprefix.mnv.recal \
--tranches-file $outprefix.mnv.tranches \
--rscript-file $outprefix.mnv.recal.plots.R;

gatk ApplyVQSR \
--java-options -Xmx${xmx} \
-R $ref_fa \
-V $outprefix.mnv.vcf.gz \
--ts-filter-level 99.0 \
-mode SNP \
--tranches-file $outprefix.mnv.tranches \
--recal-file $outprefix.mnv.recal \
-O $outprefix.mnv.vqsr.vcf.gz;
