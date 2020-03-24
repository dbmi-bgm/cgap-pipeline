#!/bin/bash

set -o pipefail

fastq1=$1
fastq2=$2
index=$3
outdir=$4
prefix=$5
nThreads=$6

if [[ $outdir != '.' ]]
then
  cd $outdir
fi

# run bwa
bwa mem -t $nThreads $index $fastq1 $fastq2 | samtools view -Shb - > $prefix.bam

if [ $? -ne 0 ];
then
    exit 1
fi
