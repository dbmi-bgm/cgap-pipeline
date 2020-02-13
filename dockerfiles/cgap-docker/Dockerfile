FROM 4dndcic/ubuntu16.04-miniconda-python36:v1
MAINTAINER Soo Lee (duplexa@gmail.com), Michele Berselli (berselli.michele@gmail.com)

# general updates & installing necessary Linux components
RUN apt-get update -y && apt-get install -y \
    bzip2 \
    gcc \
    g++ \
    git \
    less \
    libncurses-dev \
    make \
    time \
    unzip \
    vim \
    wget \
    zlib1g-dev \
    liblz4-tool \
    libbz2-dev \
    liblzma-dev \
    locales \
    parallel \
    autoconf \
    autogen \
    pkg-config \
    tabix

WORKDIR /usr/local/bin

# gatk4 & picard
RUN conda install -c bioconda -y gatk4==4.1.2.0 picard==2.20.2 pysam

# samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 && \
    tar -xjf samtools-1.9.tar.bz2 && \
    cd samtools-1.9 && \
    ./configure && \
    make && \
    cd .. && \
    ln -s samtools-1.9 samtools

# bwa
RUN wget https://github.com/lh3/bwa/archive/v0.7.17.tar.gz && \
    tar -xzf v0.7.17.tar.gz && \
    cd bwa-0.7.17 && \
    make && \
    cd .. && \
    ln -s bwa-0.7.17 bwa

# vcf tools
RUN git clone https://github.com/vcftools/vcftools.git && \
    mv vcftools vcftools_tmp && \
    cd vcftools_tmp && \
    git checkout 954e607 && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    cd ..

# bwa mem script
COPY bwa-mem-to-bam.sh .
RUN chmod +x bwa-mem-to-bam.sh

COPY bwa-mem-to-bam_no_unzip.sh .
RUN chmod +x bwa-mem-to-bam_no_unzip.sh

# BAM integrity check script
COPY integrity-check.sh .
RUN chmod +x integrity-check.sh

# VCF integrity check script
COPY vcf-integrity-check.sh .
RUN chmod +x vcf-integrity-check.sh

# add read groups script
RUN git clone https://github.com/dbmi-bgm/cgap-scripts/ && \
    cd cgap-scripts && \
    git checkout 1140e78 && \
    chmod +x AddReadGroups.py && \
    cd ..

# HaplotypeCaller parallel script
COPY HaplotypeCaller-parallel.sh .
RUN chmod +x HaplotypeCaller-parallel.sh

# CombineGVCFs parallel script
COPY CombineGVCFs-parallel.sh .
RUN chmod +x CombineGVCFs-parallel.sh

# GenotypeGVCFs parallel script
COPY GenotypeGVCFs-parallel.sh .
RUN chmod +x GenotypeGVCFs-parallel.sh

# VQSR
COPY vqsr-indel.sh .
RUN chmod +x vqsr-indel.sh

COPY vqsr-snv.sh .
RUN chmod +x vqsr-snv.sh

# CRAM
# Cramtools
RUN git clone https://github.com/enasequence/cramtools && \
    cd cramtools && \
    git checkout 0b5c9ec && \
    cd ..
COPY md5_to_fasta.py .
COPY cram_to_fastq.sh .
RUN chmod +x cram_to_fastq.sh

# pigz
RUN wget https://zlib.net/pigz/pigz-2.4.tar.gz && \
    tar -xzf pigz-2.4.tar.gz && \
    cd pigz-2.4 && \
    make && \
    cd ..

# paths
ENV PATH=/usr/local/bin/samtools/:$PATH
ENV PATH=/usr/local/bin/bwa/:$PATH
ENV PATH=/usr/local/bin/cgap-scripts/:$PATH
ENV PATH=/usr/local/bin/pigz-2.4/:$PATH

# supporting UTF-8
RUN locale-gen "en_US.UTF-8" && update-locale LC_ALL="en_US.UTF-8"
ENV LC_ALL=en_US.UTF-8

CMD ["bash"]
