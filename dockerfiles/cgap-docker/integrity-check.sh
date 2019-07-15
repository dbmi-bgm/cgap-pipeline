#!/bin/bash

filename=$1

if samtools quickcheck $filename;
then
	echo "quickcheck: OK" > integrity_check
	reads_number=`samtools view -c $filename`
	echo "number of reads: $reads_number" >> integrity_check 
else
	echo "quickcheck: FAILED" > integrity_check
fi
