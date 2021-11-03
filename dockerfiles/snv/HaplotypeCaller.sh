#!/bin/bash

# variables from command line
inputbam=$1
reference=$2
regionfile=$3
threshold=$4
ERC=$5
nthreads=$6

# self variables
directory=GVCFS/

# setting up output directory
mkdir -p $directory

# runnning HaplotypeCaller

gatk HaplotypeCaller --java-options '-Xms8g' -R $reference -O ${directory}combined.g.vcf -I $inputbam -L $regionfile -ERC $ERC --max-alternate-alleles 3 --read-filter OverclippedReadFilter -stand-call-conf $threshold -ip 50 || exit 1

# move results

mv ${directory}combined.g.vcf combined.gvcf || exit 1

# compress and index combined gvcf
bgzip combined.gvcf || exit 1
tabix -p vcf combined.gvcf.gz || exit 1
