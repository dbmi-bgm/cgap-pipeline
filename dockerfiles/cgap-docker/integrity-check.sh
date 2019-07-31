#!/bin/bash

filename=$1

if samtools quickcheck $filename;
then
	echo -e "quickcheck\tOK" > integrity_check
	reads_number=`samtools view -c $filename`
	echo -e "number_of_reads\t$reads_number" >> integrity_check 
else
	echo -e "quickcheck\tFAILED" > integrity_check
fi
