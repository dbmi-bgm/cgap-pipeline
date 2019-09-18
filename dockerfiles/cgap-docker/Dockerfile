FROM 4dndcic/ubuntu16.04-miniconda-python36:v1
MAINTAINER Soo Lee (duplexa@gmail.com), Michele Berselli (berselli.michele@gmail.com)

# 1. general updates & installing necessary Linux components
RUN apt-get update -y && apt-get install -y \
    bzip2 \
    gcc \
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
    parallel

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

# bwa mem script
COPY bwa-mem-to-bam.sh .
RUN chmod +x bwa-mem-to-bam.sh

COPY bwa-mem-to-bam_no_unzip.sh .
RUN chmod +x bwa-mem-to-bam_no_unzip.sh

# integrity check script
COPY integrity-check.sh .
RUN chmod +x integrity-check.sh

# add read groups script
RUN git clone https://github.com/dbmi-bgm/cgap-scripts/ && \
    cd cgap-scripts && \
    git checkout b432a4c && \
    chmod +x AddReadGroups.py && \
    cd ..

# hc parallel script
COPY hc-parallel.sh .
RUN chmod +x hc-parallel.sh

# paths
ENV PATH=/usr/local/bin/samtools/:$PATH
ENV PATH=/usr/local/bin/bwa/:$PATH
ENV PATH=/usr/local/bin/cgap-scripts/:$PATH

# supporting UTF-8
RUN locale-gen "en_US.UTF-8" && update-locale LC_ALL="en_US.UTF-8"
ENV LC_ALL=en_US.UTF-8

CMD ["bash"]
