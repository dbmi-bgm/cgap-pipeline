#!/bin/bash

# variables
novo_vcf=$1 # family samples need to be
            # the first three sample columns
filtered_vcf=$2
pedigree=$3
sample=$4

# get accession from file name
accession=${novo_vcf%%.*}

####### I
# remove non-trio sample columns
gunzip -c $novo_vcf | cut -f -12 > ${accession}.spl.vcf

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

# set sample in pedigree
sed "s/${sample}/${sample}_${accession}/g" $pedigree > ${pedigree%%.*}.${sample}.json

####### III
# run granite
granite validateVCF -i ${accession}.merged.vcf -o ${accession}.novo.snv.json -p ${pedigree%%.*}.${sample}.json --anchor ${sample}_${accession} --novo ${sample}_${accession}

granite validateVCF -i ${accession}.merged.vcf -o ${accession}.novo.indel.json -p ${pedigree%%.*}.${sample}.json --anchor ${sample}_${accession} --novo ${sample}_${accession} --type INS DEL
