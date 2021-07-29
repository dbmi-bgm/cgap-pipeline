#!/bin/bash

# variables from command line
reference=$1
chromosomefile=$2
nthreads=$3
shift 3 # $@ stores all the files to combine

# self variables
directory=GVCFS/

# setting up output directory
mkdir -p $directory

# creating basic command
command="gatk CombineGVCFs -L {} -O ${directory}out.{}.g.vcf -R $reference"

# adding files to combine
for arg in $@;
  do
    #command+=" -V $arg"
    command+=" -V $arg" || exit 1
  done

# running command
#cat $chromosomefile | parallel --halt 2 --jobs $nthreads $command || exit 1
cat $chromosomefile | xargs -P $nthreads -i bash -c "$command" || exit 1


# merging the results
array=(${directory}*g.vcf)

IFS=$'\n' sorted=($(sort -V <<<"${array[*]}"))
unset IFS

grep "^#" ${sorted[0]} > combined.gvcf

for filename in ${sorted[@]};
  do
    if [[ $filename =~ "M" ]]; then
      chr_M=$filename
    else
      grep -v "^#" $filename >> combined.gvcf
      rm -f $filename ${filename}.idx
    fi
  done

if [[ -v  chr_M  ]]; then
  grep -v "^#" $chr_M >> combined.gvcf
  rm -f $chr_M ${chr_M}.idx
fi

# compress and index combined gvcf
bgzip combined.gvcf || exit 1
tabix -p vcf combined.gvcf.gz || exit 1
