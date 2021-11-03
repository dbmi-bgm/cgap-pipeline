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

# runnning HaplotypeCaller in parallel
#cat $regionfile | parallel --halt 2 --jobs $nthreads "gatk PrintReads --java-options '-Xms2g' -I $inputbam --interval-padding 500 -L {} -O {}.sharded.bam; if [[ -e {}.sharded.bam ]]; then gatk HaplotypeCaller --java-options '-Xms8g' -R $reference -O ${directory}out.{}.g.vcf -I {}.sharded.bam -L {} -ERC $ERC --max-alternate-alleles 3 --read-filter OverclippedReadFilter -stand-call-conf $threshold; fi; rm {}.sharded.ba*" || exit 1
cat $regionfile | xargs -P $nthreads -i bash -c "gatk PrintReads --java-options '-Xms2g' -I $inputbam --interval-padding 500 -L {} -O {}.sharded.bam || exit 1; if [[ -e {}.sharded.bam ]] || exit 1; then gatk HaplotypeCaller --java-options '-Xms8g' -R $reference -O ${directory}out.{}.g.vcf -I {}.sharded.bam -L {} -ERC $ERC --max-alternate-alleles 3 --read-filter OverclippedReadFilter -stand-call-conf $threshold || exit 1; fi; rm {}.sharded.ba*" || exit 1

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
