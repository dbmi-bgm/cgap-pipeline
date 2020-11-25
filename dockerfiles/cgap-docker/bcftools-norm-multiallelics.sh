#!/bin/bash

# variables from command line
input_vcf=$1

# run bcftools
bcftools norm --multiallelics - -o split.vcf -O v $input_vcf

# compress and index output vcf
bgzip split.vcf || exit 1
tabix -p vcf split.vcf.gz || exit 1
