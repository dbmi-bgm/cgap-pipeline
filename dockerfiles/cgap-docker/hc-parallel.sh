#!/bin/bash

inputbam=$1
reffa=$2
regionfile=$3

outdir=out_gvcfs

mkdir -p $outdir
cat $regionfile | parallel --jobs 24 "gatk PrintReads --java-options '-Xms2g' -I $inputbam --interval-padding 500 -L {} -O {}.sharded.bam; if [[ -e {}.sharded.bam ]]; then gatk HaplotypeCaller --java-options '-Xms8g' -R $reffa -O $outdir/out_full.{}.g.vcf.gz -I {}.sharded.bam -L {} -ERC GVCF --max-alternate-alleles 3 --read-filter OverclippedReadFilter -stand-call-conf 0; fi; rm {}.sharded.ba*"

