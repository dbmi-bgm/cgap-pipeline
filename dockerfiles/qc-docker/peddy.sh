#!/bin/bash

# Command line variables
pedigree=$1
vcf_file=$2
family=$3
nthreads=$4

# Creating PED file
granite toPED -o pedigree.ped --family $family -p $pedigree

# Running peddy
python -m peddy -p $nthreads --plot --sites hg38 --prefix peddy $vcf_file pedigree.ped

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
