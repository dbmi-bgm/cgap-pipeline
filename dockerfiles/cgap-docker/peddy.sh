#!/bin/bash

# Command line variables
pedigree=$1
vcf_file=$2
family=$3
nthreads=$4

# Preparing the input vcf file
gunzip -c $vcf_file > input.vcf

py_script="
fo = open('output.vcf', 'w')
with open('input.vcf') as fi:
     for line in fi:
         if line.startswith('#'):
             fo.write(line)
         else:
             CHROM, POS, ID, REF, ALT, QUAL, FILTER, INFO, FORMAT = line.rstrip().split('\t')[:9]
             GTS = line.rstrip().split('\t')[9:]
             fo.write('{0}\t{1}\t{2}\t{3}\t{4}\t{5}\t{6}\t.\t{7}'.format(CHROM, POS, ID, REF, ALT, QUAL, FILTER, FORMAT))
             for GT in GTS:
                 fo.write('\t' + GT)
             fo.write('\n')
fo.close()
"

python -c "$py_script"

# Indexing input vcf file
bgzip output.vcf
tabix -p vcf output.vcf.gz

echo $pedigree > pedigree.json

# Creating PED file
granite toPED -o pedigree.ped --family $family -p pedigree.json

# Running peddy
python -m peddy -p $nthreads --plot --sites hg38 --prefix peddy output.vcf.gz pedigree.ped

# Parse peddy to json
py_script="
import sys, os
import json

data = {}
data_json = []

with open('peddy.het_check.csv') as fi:
    for i, line in enumerate(fi):
        if i != 0:
            ID, ancestry = line.rstrip().split(',')[0], line.rstrip().split(',')[11]
            data.setdefault(ID, [ancestry])

with open('peddy.sex_check.csv') as fi:
    for i, line in enumerate(fi):
        if i != 0:
            ID, sex = line.rstrip().split(',')[0], line.rstrip().split(',')[6]
            data[ID].append(sex)

for ID in data:
    tmp_dict = {
        'name': ID,
        'predicted sex': data[ID][1],
        'predicted ancestry': data[ID][0]
    }
    data_json.append(tmp_dict)

dict_json = {'ancestry and sex prediction': data_json}

with open('output.json', 'w') as fo:
    json.dump(dict_json, fo, indent=2, sort_keys=False)
"

python -c "$py_script"
