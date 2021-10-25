#!/bin/bash

# variables from command line
dbSNP_vcf=$1
sample_vcf=$2
regionfile=$3
nthreads=$4

# modifiy the sample_vcf variable to create
sample_vcf_path_stripped=${sample_vcf##*/}
sample_vcf_out=fixed_${sample_vcf_path_stripped%%.*}.vcf

## self variables
directory=dbSNP/

# setting up output directory
mkdir -p $directory || { echo >&2 "FAILED TO CREATE DIR"; exit 1; }

cd $directory || { echo >&2 "FAILED TO CD TO DIR"; exit 1; }

# grab header from sample_vcf and create chr0:header

gunzip -c $sample_vcf | grep '^#' > chr0:header || { echo >&2 "FAILED TO CREATE HEADER FILE"; exit 1; }

# running dbSNP rsID fixer

#cat $regionfile | parallel --halt 2 --jobs $nthreads python3 /usr/local/bin/dbSNP_ID_fixer.py -db $dbSNP_vcf --inputvcf $sample_vcf --regionfile {} || exit 1
cat $regionfile | xargs -P $nthreads -i python3 /usr/local/bin/dbSNP_ID_fixer.py -db $dbSNP_vcf --inputvcf $sample_vcf --regionfile {} || { echo >&2 "FAILED DURING RUN"; exit 1; }

# merging the results
array=(*chr*:*)

IFS=$'\n' sorted=($(sort -V <<<"${array[*]}"))
unset IFS

for filename in ${sorted[@]};
  do
    if [[ $filename =~ "M" ]]; then
      chr_M=$filename
    else
      cat $filename >> $sample_vcf_out
      rm $filename
    fi
  done

if [[ ! -z "$chr_M" ]]; then
  cat $chr_M >> $sample_vcf_out
  rm $chr_M
fi

mv $sample_vcf_out ../ || { echo >&2 "FAILED TO MV OUTPUT "; exit 1; }
cd ../ || { echo >&2 "FAILED TO CD SECOND TIME"; exit 1; }

# compress and index combined gvcf
bgzip $sample_vcf_out || { echo >&2 "FAILED TO BGZIP"; exit 1; }
tabix -p vcf ${sample_vcf_out}.gz || { echo >&2 "FAILED to TABIX"; exit 1; }

# test that dbSNP output is not empty (known bug that requires rerun)
line_count=`bgzip -cd ${sample_vcf_out}.gz | wc -l`
if [ "$line_count" == "0" ]; then { echo >&2 "FAILED LINECOUNT WAS ZERO"; exit 1; }; fi
