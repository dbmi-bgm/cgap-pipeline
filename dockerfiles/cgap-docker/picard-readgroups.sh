#!/bin/bash

inputfile=$1
rgid=$2
rglb=$3
rgpl=$4
rgpu=$5
rgsm=$6

filename=${inputfile##*/}

# run AddOrReplaceReadGroups
picard AddOrReplaceReadGroups I=$inputfile O=${filename%.*}_rg.bam RGID=$rgid RGLB=$rglb RGPL=$rgpl RGPU=$rgpu RGSM=$rgsm
