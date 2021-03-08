#!/bin/bash

# variables from command line
input_vcf=$1

# run
/usr/local/bin/cgap-scripts/samplegeno.py -i $input_vcf -o output.vcf

# compress and index output vcf
bgzip output.vcf || exit 1
tabix -p vcf output.vcf.gz || exit 1
