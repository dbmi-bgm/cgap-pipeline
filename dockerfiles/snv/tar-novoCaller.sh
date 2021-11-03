#!/bin/bash

# variables from command line
input_vcf=$1
outputfile=$2
unrelated_tar=$3
trio_tar=$4
ppthr=$5
aftag=$6
afthr=$7
afthr_unrelated=$8
ADthr=$9

# untar files
tar -xf $unrelated_tar
tar -xf $trio_tar

# create command line
command="granite novoCaller -i $input_vcf -o $outputfile -u ${unrelated_tar}.index -t ${trio_tar}.index"

if [ ! $ppthr == 0 ];
  then
    command+=" --ppthr $ppthr"
fi

if [ ! -z "$aftag" ];
  then
    command+=" --aftag $aftag"
fi

if [ ! $afthr == 0 ];
  then
    command+=" --afthr $afthr"
fi

if [ ! $afthr_unrelated == 0 ];
  then
    command+=" --afthr_unrelated $afthr_unrelated"
fi

if [ ! $ADthr == 0 ];
  then
    command+=" --ADthr $ADthr"
fi

# run command
eval $command || exit 1

# sorting output vcf
grep "^#" $outputfile > sorted.vcf
grep -v "^#" $outputfile | sort -V -k1,1 -k2,2n >> sorted.vcf

# compress and index output vcf
bgzip sorted.vcf || exit 1
tabix -p vcf sorted.vcf.gz || exit 1
