#!/bin/bash

# variables from command line
input_vcf=$1
resources_mti=$2
regionfile=$3
nthreads=$4
micro_annotation=$5  # 1 or 0
chainfile=$6

# get resources tar name
resources_json=${resources_mti%.*}.json

# self variables
directory=VCFS/

# setting up output directory
mkdir -p $directory

# command
if [[ $micro_annotation == "1" ]]; then
    additional_options="-genoinfo -split_multi_allelic_variant -single_source_mode"
else
    additional_options="-clean_tag MUTANNO gnomADgenome CLINVAR SpliceAI -hg19 -chain $chainfile"
fi

command="tabix -h $input_vcf {} > {}.sharded.vcf; if [[ -e {}.sharded.vcf ]]; then mutanno annot -vcf {}.sharded.vcf -out ${directory}{}.ann.vcf -ds $resources_json -sourcefile $resources_mti $additional_options; fi; rm {}.sharded.vcf"

# runnning annot in parallel
cat $regionfile | parallel --halt 2 --jobs $nthreads $command || exit 1

# merging the results
array=(${directory}*.ann.vcf)

IFS=$'\n' sorted=($(sort -V <<<"${array[*]}"))
unset IFS

grep "^#" ${sorted[0]} > combined.ann.vcf

for filename in ${sorted[@]};
  do
    if [[ $filename =~ "M" ]]; then
      chr_M=$filename
    else
      grep -v "^#" $filename >> combined.ann.vcf
      rm -f $filename
    fi
  done

if [[ -v  chr_M  ]]; then
  grep -v "^#" $chr_M >> combined.ann.vcf
  rm -f $chr_M
fi

# compress and index combined gvcf
pbgzip -ifn$nthreads combined.ann.vcf
tabix -p vcf combined.ann.vcf.gz