FROM ubuntu:16.04

# updates & installing necessary Linux components
RUN apt-get update -y && apt-get install -y \
    bzip2 \
    bwa \
    samtools

WORKDIR /usr/local/bin
COPY bwa-mem-to-bam.sh .
RUN chmod +x bwa-mem-to-bam.sh
