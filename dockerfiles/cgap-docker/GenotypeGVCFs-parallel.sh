#!/bin/bash

# variables from command line
input_gvcf=$1
reference=$2
dbsnp=$3
chromosomefile=$4
nthreads=$5

# self variables
directory=VCFS/

# setting up output directory
mkdir -p $directory

# creating basic command
command="gatk --java-options \"-Xmx4g\" GenotypeGVCFs -V $input_gvcf -R $reference --dbsnp $dbsnp -verbosity INFO -L {} -O ${directory}out.{}.vcf --annotations-to-exclude ExcessHet"

# running command
#cat $chromosomefile | parallel --halt 2 --jobs $nthreads $command || exit 1
cat $chromosomefile | xargs -P $nthreads -i bash -c "$command" || exit 1


# merging the results
array=(${directory}*.vcf)

IFS=$'\n' sorted=($(sort -V <<<"${array[*]}"))
unset IFS

grep "^#" ${sorted[0]} > combined.vcf

for filename in ${sorted[@]};
  do
    if [[ $filename =~ "M" ]]; then
      chr_M=$filename
    else
      grep -v "^#" $filename >> combined.vcf
      rm -f $filename ${filename}.idx
    fi
  done

if [[ -v  chr_M  ]]; then
  grep -v "^#" $chr_M >> combined.vcf
  rm -f $chr_M ${chr_M}.idx
fi

# compress and index combined gvcf
bgzip combined.vcf || exit 1
tabix -p vcf combined.vcf.gz || exit 1
