#!/bin/bash

# variables from command line
input_vcf_1=$1
input_vcf_2=$2

# saving header
grep "^#" $input_vcf_1 > sorted_tmp.vcf

# getting variants
grep -v "^#" $input_vcf_1 > tmp.vcf
grep -v "^#" $input_vcf_2 >> tmp.vcf

# sorting variants and removing duplicates
sort -V -k1,1 -k2,2n tmp.vcf >> sorted_tmp.vcf

# removing duplicates
duplines_vcf.py -i sorted_tmp.vcf -o sorted.vcf

# compress and index output vcf
bgzip sorted.vcf || exit 1
tabix -p vcf sorted.vcf.gz || exit 1
