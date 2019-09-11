#!/bin/bash

INPUT_BAM=$1
MEMORY=$2 # example '5G'

echo
echo "RUN BAMSTAT"
bamstat.py $INPUT_BAM > ${INPUT_BAM}.stat

echo
echo "RUN PICARD"
picard -Xms${MEMORY} -Xmx${MEMORY} CollectMultipleMetrics VALIDATION_STRINGENCY=LENIENT INPUT=$INPUT_BAM OUTPUT=${INPUT_BAM}.cmm

# echo
# echo "RUN BEDTOOLS"
# bedtools genomecov -ibam $INPUT_BAM > ${INPUT_BAM}.hist

echo
echo "RUN QCBOARD"
qcboard_v1.py -bam $INPUT_BAM -out OUTPUT
