#!/bin/bash

# Command line variables
vcf_file=$1

# Counting variants
uniq_var=$(gunzip -c $vcf_file | grep -v '^#' | cut -f 1,2 | uniq | wc -l)

# Printing result as tsv
echo -e "unique_variants_in_vcf\t${uniq_var}" > uniq_variants
