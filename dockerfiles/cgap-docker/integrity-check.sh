#!/bin/bash

filename=$1
count=$2

if samtools quickcheck $filename;
then
	echo -e "quickcheck\tOK" > integrity_check
	if [ $count -eq 1 ];
	then
		alignments_number=`samtools view -c $filename`
		echo -e "number_of_lines\t$alignments_number" >> integrity_check
	fi
else
	echo -e "quickcheck\tFAILED" > integrity_check
fi
