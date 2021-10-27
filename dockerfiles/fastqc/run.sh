#!/bin/bash

inputfile=$1
nthread=$2
outdir=$3

mkdir -p $outdir
fastqc -t $nthread -o $outdir $inputfile
