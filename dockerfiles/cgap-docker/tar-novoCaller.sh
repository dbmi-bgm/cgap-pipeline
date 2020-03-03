#!/bin/bash

# variables from command line
input_vcf=$1
outputfile=$2
unrelated_tar=$3
trio_tar=$4
ppthr=$5
aftag=$6
afthr=$7

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

# run command
eval $command
