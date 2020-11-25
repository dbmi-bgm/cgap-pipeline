#!/bin/bash

# variables from command line
input_vcf=$1
reference=$2
regionfile=$3
# data sources
vep_tar_gz=$4
clinvar_gz=$5
dbnsfp_gz=$6
fordownload_tar_gz=$7
spliceai_snv_gz=$8
spliceai_indel_gz=$9
gnomad_gz=${10}
# parameters
nthreads=${11}
version=${12} # 101
assembly=${13} # GRCh38

# self variables
directory=VCFS/

# rename with version
dbnsfp=dbNSFP4.1a.gz

# rename dbNSFP
ln -s $dbnsfp_gz $dbnsfp
ln -s ${dbnsfp_gz}.tbi ${dbnsfp}.tbi
ln -s ${dbnsfp_gz%.*}.readme.txt dbnsfp.readme.txt

# unpack data sources
tar -xzf $vep_tar_gz
tar -xzf ${vep_tar_gz%%.*}.plugins.tar.gz
tar -xzf $fordownload_tar_gz

# setting up output directory
mkdir -p $directory

# command line VEP
# plugins
plugin_entscan="--plugin MaxEntScan,fordownload"
plugin_dbnsfp="--plugin dbNSFP,${dbnsfp},ALL"
plugin_spliceai="--plugin SpliceAI,snv=${spliceai_snv_gz},indel=${spliceai_indel_gz}"

plugins="--dir_plugins VEP_plugins --plugin SpliceRegion,Extended --plugin TSSDistance $plugin_entscan $plugin_dbnsfp $plugin_spliceai"

# customs
cutsom_clinvar="--custom ${clinvar_gz},ClinVar,vcf,exact,0,ALLELEID,CLNSIG,CLNREVSTAT,CLNDN,CLNDISDB"
custom_gnomad="--custom ${gnomad_gz},gnomADg,vcf,exact,0,AC,AC-XX,AC-XY,AC-afr,AC-ami,AC-amr,AC-asj,AC-eas,AC-fin,AC-mid,AC-nfe,AC-oth,AC-sas,AF,AF-XX,AF-XY,AF-afr,AF-ami,AF-amr,AF-asj,AF-eas,AF-fin,AF-mid,AF-nfe,AF-oth,AF-sas,AF_popmax,AN,AN-XX,AN-XY,AN-afr,AN-ami,AN-amr,AN-asj,AN-eas,AN-fin,AN-mid,AN-nfe,AN-oth,AN-sas,nhomalt,nhomalt-XX,nhomalt-XY,nhomalt-afr,nhomalt-ami,nhomalt-amr,nhomalt-asj,nhomalt-eas,nhomalt-fin,nhomalt-mid,nhomalt-nfe,nhomalt-oth,nhomalt-sas"

customs="$cutsom_clinvar $custom_gnomad"

# options and full command line
options="--hgvs --fasta $reference --assembly $assembly --use_given_ref --offline --cache_version $version --dir_cache . --everything --force_overwrite --vcf"
command="tabix -h $input_vcf {} > {}.sharded.vcf; if [[ -e {}.sharded.vcf ]]; then if grep -q -v '^#' {}.sharded.vcf; then vep -i {}.sharded.vcf -o ${directory}{}.vep.vcf $options $plugins $customs; fi; fi; rm {}.sharded.vcf"

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

# compress and index output vcf
bgzip combined.vep.vcf || exit 1
tabix -p vcf combined.vep.vcf.gz || exit 1
