#!/bin/bash

# Command line variables
vcf_file=$1

# Counting variants
uniq_var=$(gunzip -c $vcf_file | grep -v '^#' | cut -f 1,2 | uniq | wc -l | sed 's/^[ \t]*//;s/[ \t]*$//')

# Printing result as tsv
echo -e "{\"total unique variants in vcf\":\"${uniq_var}\"}" > uniq_variants.json
