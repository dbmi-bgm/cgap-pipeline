#!/bin/bash

# variables from command line
input_bam=$1
reference=$2
bqsr_report=$3
static_1=$4
static_2=$5
static_3=$6
nthreads=$7

# splitting bam file
echo "--------------------"
echo "splitting bam..."
echo "--------------------"

split_bam.py -i $input_bam -t $nthreads

# running ApplyBQSR in parallel
echo "--------------------"
echo "running ApplyBQSR..."
echo "--------------------"

static_args="--static-quantized-quals $static_1 --static-quantized-quals $static_2 --static-quantized-quals $static_3"
command_run="gatk ApplyBQSR -I {} -O {}_recalibrated.bam --use-original-qualities -R $reference --bqsr $bqsr_report $static_args --create-output-bam-index false"

find -name "*chunk.bam" | xargs -n1 -P $nthreads -i bash -c "$command_run || exit 1; rm {}" || exit 1

# merging the results
echo "--------------------"
echo "merging results..."
echo "--------------------"

command_cat="samtools cat -o recalibrated.bam" # we can update samtools and add the multi-threading (-@) option

array=(*_recalibrated.bam)

IFS=$'\n' sorted=($(sort -V <<<"${array[*]}"))
unset IFS

for filename in ${sorted[@]};
  do
    command_cat+=" $filename"
  done

command_cat+=" || exit 1"

echo $command_cat
eval $command_cat

# indexing the results
echo "--------------------"
echo "indexing results..."
echo "--------------------"

samtools index -@ $nthreads recalibrated.bam || exit 1
