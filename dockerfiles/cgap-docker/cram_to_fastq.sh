#!/bin/sh
input_cram=$1
out_prefix=$2  # output files will be $out_prefix.1.fastq.gz and $out_prefix.2.fastq.gz
nthreads=$3

CRAMTOOLS_JAR=/usr/local/bin/cramtools/cramtools-3.0.jar

# retrieving reference fasta
java -jar $CRAMTOOLS_JAR getref -I $input_cram -F $reflist
python /usr/local/bin/md5_to_fasta.py -i $reflist -o $ref_fasta
samtools faidx $ref_fasta

# cram to bam
samtools view -hb -T $ref_fasta $input_cram > $bam

# bam to fastq
mkfifo 1.fastq
mkfifo 2.fastq
samtools collate -O $bam | samtools fastq -1 1.fastq -2 2.fastq -@$nthreads -
gzip -c 1.fastq > $out_prefix.1.fastq.gz
gzip -c 2.fastq > $out_prefix.2.fastq.gz
