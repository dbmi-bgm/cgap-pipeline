#!/bin/bash
shopt -s extglob
out_prefix="out"
nthreads=1
reflist=tmp_md5list
bam=tmp.bam

printHelpAndExit() {
    echo "Usage: ${0##*/} [-p nthreads] -i input_cram -o out_prefix [-f input_fasta] [-m input_md5]"
    echo "-i input_cram : input file in .cram format"
    echo "-o out_prefix : default output prefix (output files will be <out_prefix>.1.fastq.gz and <out_prefix>.2.fastq.gz)"
    echo "-p nthreads : default 1"
    echo "-f input_fasta : input reference file in fasta format (optional)"
    echo "-m input_md5 : file containing md5 of every chromosome of the reference fasta (optional)"
    exit "$1"
}

while getopts "i:o:p:f:m:h" opt; do
    case $opt in
        i) input_cram=$OPTARG;;
        o) out_prefix=$OPTARG;;
        p) nthreads=$OPTARG;;
        f) input_fasta=$OPTARG;;
        m) input_md5=$OPTARG;;
        h) printHelpAndExit 0;;
        [?]) printHelpAndExit 1;;
        esac
done

if [[ -z $input_cram ]]; then
    echo "input cram file is a required argument."
    printHelpAndExit 1
fi

if [[ -z $input_md5 && ! -z $input_fasta ]]; then
    echo "To use input md5, provide a matching reference fasta file as well."
    printHelpAndExit 1
fi

if [[ ! -z $input_md5 && -z $input_fasta ]]; then
    echo "To use reference fasta, provide a matching md5 file as well."
    printHelpAndExit 1
fi


CRAMTOOLS_JAR=/usr/local/bin/cramtools/cramtools-3.0.jar

# retrieving reference fasta
java -jar $CRAMTOOLS_JAR getref -I $input_cram -F $reflist || { echo "cannot get reference md5"; exit 1; }
if [[ ! -z $input_md5 && ! -z $input_fasta ]]; then
    if [[ -z $(diff $input_md5 $reflist) ]]; then
        # the md5 values match the provided reference/md5, no need to download reference
        ref_fasta=$input_fasta
    fi
fi
if [[ -z $ref_fasta ]]; then
    # download and combine reference sequences
    ref_fasta=ref.fa
    python /usr/local/bin/md5_to_fasta.py -i $reflist -o $ref_fasta || { echo "cannot download references"; exit 1; }
fi
if [[ ! -e $ref_fasta.fai ]]; then
    # create index for reference fasta
    samtools faidx $ref_fasta || { echo "cannot create index for the fasta file $ref_fasta"; exit 1; }
fi


# cram to bam
samtools view -@$nthreads -hb -T $ref_fasta $input_cram > $bam || { echo "cannot convert cram to bam."; exit 1; }

# bam integrity check
integrity-check.sh $bam 0
if [[ $(cat integrity_check |cut -f2) != "OK" ]]; then
    echo "Bam integrity check failed."
    exit 1;
fi

# bam to fastq
samtools collate -@$nthreads -O $bam | samtools fastq -1 $out_prefix.1.fastq -2 $out_prefix.2.fastq -@$nthreads - || { echo "cannot convert bam to fastq."; exit 1; }
rm -rf $bam  # save space
pigz $out_prefix.1.fastq || { echo "Cannot compress $out_prefix.1.fastq"; exit 1; }
pigz $out_prefix.2.fastq || { echo "Cannot compress $out_prefix.2.fastq"; exit 1; }

