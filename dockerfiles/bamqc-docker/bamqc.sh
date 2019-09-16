#!/bin/bash

INPUT_BAM=$1
XMX=$2 # example '5G'
XMS=$3 # example '5G'

echo
echo "RUN BAMSTAT"
bamstat.py $INPUT_BAM > ${INPUT_BAM}.stat

echo
echo "RUN PICARD"
picard -Xms${XMS} -Xmx${XMX} CollectMultipleMetrics VALIDATION_STRINGENCY=LENIENT INPUT=$INPUT_BAM OUTPUT=${INPUT_BAM}.cmm

# echo
# echo "RUN BEDTOOLS"
# bedtools genomecov -ibam $INPUT_BAM > ${INPUT_BAM}.hist

echo
echo "RUN QCBOARD"
qcboard.py -bam $INPUT_BAM -out qcboard_bam -temp /usr/local/bin/qcboard_bamqc.html

echo
echo "ZIPPING RESULTS"
mkdir qcboard_bam
cp qcboard_bam.html qcboard_bam
cp qcboard_bam.json qcboard_bam
zip -r qcboard_bam.zip qcboard_bam
