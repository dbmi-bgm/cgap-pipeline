#!/bin/bash

# variables
trio_vcf=$1 # family samples need to be
            # the first three sample columns
filtered_vcf=$2
pedigree=$3
sample_1=$4
sample_2=$5

# get accession from file name
accession=${trio_vcf%%.*}

####### I
# remove non-trio sample columns
gunzip -c $trio_vcf | cut -f -12 > ${accession}.spl.vcf

# get trio sample names
read -r -a array <<< "$(grep '^#CHROM' ${accession}.spl.vcf | cut -f 10-)"

# create file for reheader
echo "${array[0]} ${array[0]}_${accession}" > header
echo "${array[1]} ${array[1]}_${accession}" >> header
echo "${array[2]} ${array[2]}_${accession}" >> header

# compress vcf for bcftools
bgzip ${accession}.spl.vcf

# reheader and create index
bcftools reheader -s header -o ${accession}.rhd.vcf.gz ${accession}.spl.vcf.gz
tabix -p vcf ${accession}.rhd.vcf.gz

####### II
# merge with filtered file
# requires index
bcftools merge -o ${accession}.merged.vcf ${filtered_vcf} ${accession}.rhd.vcf.gz

# set samples in pedigree
sed "s/${sample_1}/${sample_1}_${accession}/g" $pedigree > ${pedigree%%.*}.${sample_1}.json
sed "s/${sample_2}/${sample_2}_${accession}/g" $pedigree > ${pedigree%%.*}.${sample_2}.json

####### III
# run granite
granite validateVCF -i ${accession}.merged.vcf -o ${accession}.het.json -p ${pedigree%%.*}.${sample_1}.json ${pedigree%%.*}.${sample_2}.json --anchor ${sample_1}_${accession} ${sample_2}_${accession} --het ${sample_1}_${accession} ${sample_2}_${accession}
