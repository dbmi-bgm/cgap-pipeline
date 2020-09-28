#!/bin/bash

# variables from command line
file=$1

# sorting output vcf
grep "^#" $file > sorted.vcf
grep -v "^#" $file | sort -V -k1,1 -k2,2n >> sorted.vcf

# compress and index output vcf
bgzip sorted.vcf || exit 1
tabix -p vcf sorted.vcf.gz || exit 1
