#!/bin/bash

# variables from command line
input_vcf=$1
reference=$2
resources_tar_gz=$3
plugins_tar_gz=$4
regionfile=$5
resources_mti=$6
nthreads=$7
version=$8 #99
assembly=$9 #GRCh38

# self variables
directory=VCFS/

# get resources tar name
resources_json=${resources_mti%.*}.json

# unpack data sources
tar -xzf $resources_tar_gz
tar -xzf $plugins_tar_gz

# setting up output directory
mkdir -p $directory

# preparing the input vcf file
gunzip -c $input_vcf > input.vcf

# get indels only
py_script="
fo = open('input.indels.vcf', 'w')
with open('input.vcf') as fi:
    for line in fi:
        if line.startswith('#'):
            fo.write(line)
        else:
            CHROM, POS, ID, REF, ALT, QUAL, FILTER, INFO, FORMAT = line.rstrip().split('\t')[:9]
            if len(REF) > 1 or len(ALT) > 1:
                fo.write(line)
fo.close()
"

python -c "$py_script"

# compress input.indels.vcf
bgzip input.indels.vcf
tabix -p vcf input.indels.vcf.gz

# command line VEP
options="--hgvs --assembly $assembly --use_given_ref --offline --cache_version $version --dir_cache . --everything --force_overwrite --vcf --plugin MaxEntScan,VEP_plugins-release-${version}/fordownload --plugin TSSDistance --dir_plugins VEP_plugins-release-${version} --plugin SpliceRegion,Extended"

command="tabix -h input.indels.vcf.gz {} > {}.sharded.vcf; if [[ -e {}.sharded.vcf ]]; then if grep -q -v '^#' {}.sharded.vcf; then vep -i {}.sharded.vcf -o ${directory}{}.vep.vcf --fasta $reference $options; fi; fi; rm {}.sharded.vcf"

# runnning VEP in parallel
echo "Running VEP"
cat $regionfile | parallel --halt 2 --jobs $nthreads $command || exit 1

# merging the results
echo "Merging vcf files"
array=(${directory}*.vep.vcf)

IFS=$'\n' sorted=($(sort -V <<<"${array[*]}"))
unset IFS

grep "^#" ${sorted[0]} > combined.vep.vcf

for filename in ${sorted[@]};
  do
    if [[ $filename =~ "M" ]]; then
      chr_M=$filename
    else
      grep -v "^#" $filename >> combined.vep.vcf
      rm -f $filename
    fi
  done

if [[ -v  chr_M  ]]; then
  grep -v "^#" $chr_M >> combined.vep.vcf
  rm -f $chr_M
fi

# creating mti
micro="mutanno preprocess -infile combined.vep.vcf -ds $resources_json -out output.microannot.mti -vep2mti; bgzip output.microannot.mti; tabix -p vcf output.microannot.mti.gz"

full="mutanno preprocess -infile combined.vep.vcf -out output.fullannot.mti -vep2mti; bgzip output.fullannot.mti; tabix -p vcf output.fullannot.mti.gz"

echo "Creating mti files"
(echo $micro; echo $full) | parallel --halt 2 || exit 1
