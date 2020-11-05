#!/bin/bash
# This script generates a pair of gzipped fastq files from a bam file by first collating reads and then using samtools fastq.
# The fastq files are gzipped using pigz.

shopt -s extglob
out_prefix="out"
nthreads=1

printHelpAndExit() {
    echo "Usage: ${0##*/} [-p nthreads] -i input_bam -o out_prefix"
    echo "-i input_bam : input file in .bam format"
    echo "-o out_prefix : default output prefix (output files will be <out_prefix>.1.fastq.gz and <out_prefix>.2.fastq.gz)"
    echo "-p nthreads : default 1"
    exit "$1"
}

while getopts "i:o:p:f:m:h" opt; do
    case $opt in
        i) input_bam=$OPTARG;;
        o) out_prefix=$OPTARG;;
        p) nthreads=$OPTARG;;
        h) printHelpAndExit 0;;
        [?]) printHelpAndExit 1;;
        esac
done

if [[ -z $input_bam ]]; then
    echo "input bam file is a required argument."
    printHelpAndExit 1
fi


# bam integrity check
integrity-check.sh $input_bam 0
if [[ $(cat integrity_check |cut -f2) != "OK" ]]; then
    echo "Bam integrity check failed."
    exit 1;
fi

# bam to fastq
samtools collate -@$nthreads -O $input_bam | samtools fastq -0 /dev/null -s /dev/null -1 $out_prefix.1.fastq -2 $out_prefix.2.fastq -@$nthreads - || { echo "cannot convert bam to fastq."; exit 1; }

# fastq line number check
if [[ $(wc -l $out_prefix.1.fastq | cut -d' ' -f1) != $(wc -l $out_prefix.2.fastq | cut -d' ' -f1) ]]; then
    echo "Fastq line number check failed."
    exit 1;
fi

pigz $out_prefix.1.fastq || { echo "Cannot compress $out_prefix.1.fastq"; exit 1; }
pigz $out_prefix.2.fastq || { echo "Cannot compress $out_prefix.2.fastq"; exit 1; }

