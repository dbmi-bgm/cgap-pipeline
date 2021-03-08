#!/bin/bash

# variables from command line
dbSNP_vcf=$1
sample_vcf=$2
regionfile=$3
nthreads=$4

# modifiy the sample_vcf variable to create
sample_vcf_path_stripped=${sample_vcf##*/}
sample_vcf_out=fixed_${sample_vcf_path_stripped%%.*}.vcf

## self variables
directory=`pwd`

# grab header from sample_vcf and create chr0:header
python3 vcf_write_header.py -i $sample_vcf

# running dbSNP rsID fixer

cat $regionfile | parallel --halt 2 --jobs $nthreads python3 dbSNP_ID_fixer.py -db $dbSNP_vcf --inputvcf $sample_vcf --regionfile {} || exit 1

# merging the results
array=(${directory}/*chr*:*)

IFS=$'\n' sorted=($(sort -V <<<"${array[*]}"))
unset IFS

for filename in ${sorted[@]};
  do
    if [[ $filename =~ "M" ]]; then
      chr_M=$filename
    else
      cat $filename >> $sample_vcf_out
      rm $filename
    fi
  done

if [[ ! -z "$chr_M" ]]; then
  cat $chr_M >> $sample_vcf_out
  rm $chr_M
fi


# compress and index combined gvcf
bgzip $sample_vcf_out || exit 1
tabix -p vcf ${sample_vcf_out}.gz || exit 1
