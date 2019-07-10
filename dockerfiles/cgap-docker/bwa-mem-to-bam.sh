#!/bin/bash

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

# unzip fastq files
if [[ $fastq1 =~ \.gz$ ]]
then
  cp $fastq1 fastq1.gz
  gunzip fastq1.gz
elif [[ $fastq1 =~ \.bz2$ ]]
then
  cp $fastq1 fastq1.bz2
  bzip2 -d fastq1.bz2
else
  cp $fastq1 fastq1
fi
  fastq1=fastq1

if [[ $fastq2 =~ \.gz$ ]]
then
  cp $fastq2 fastq2.gz
  gunzip fastq2.gz
elif [[ $fastq2 =~ \.bz2$ ]]
then
  cp $fastq2 fastq2.bz2
  bzip2 -d fastq2.bz2
else
  cp $fastq2 fastq2
fi
  fastq2=fastq2

# run bwa
bwa mem -t $nThreads $index $fastq1 $fastq2 | samtools view -Shb - > $prefix.bam
