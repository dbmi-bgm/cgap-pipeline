#!/bin/bash

# variables from command line
input_vcf=$1
resources_tar=$2
regionfile=$3
blocksize=$4
nthreads=$5

# get resources tar name
resources_json=${resources_tar%.*}.json

# untar resources
tar -xf $resources_tar

# self variables
directory=VCFS/

# setting up output directory
mkdir -p $directory

# command
command="tabix -h $input_vcf {} > {}.sharded.vcf; if [[ -e {}.sharded.vcf ]]; then mutanno.py annot -vcf {}.sharded.vcf -out ${directory}{}.ann.vcf -ds $resources_json -blocksize $blocksize; fi; rm {}.sharded.vcf"

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
bgzip combined.ann.vcf
tabix -p vcf combined.ann.vcf.gz
