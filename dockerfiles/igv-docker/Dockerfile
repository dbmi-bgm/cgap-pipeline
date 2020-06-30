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
    autotools-dev \
    automake \
    pkg-config \
    tabix \
    xvfb \
    yasm

WORKDIR /usr/local/bin

# samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 && \
    tar -xjf samtools-1.9.tar.bz2 && \
    rm -rf samtools-1.9.tar.bz2 && \
    cd samtools-1.9 && \
    ./configure && \
    make && \
    cd .. && \
    ln -s samtools-1.9 samtools

# Java 11
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:openjdk-r/ppa -y && \
    apt-get update && \
    apt-get install -y openjdk-11-jdk

# IGV
RUN wget https://data.broadinstitute.org/igv/projects/downloads/2.8/IGV_2.8.6.zip && \
    unzip IGV_2.8.6.zip && \
    ln -s IGV_2.8.6 IGV

# env paths
ENV PATH=/usr/local/bin/samtools/:$PATH
ENV PATH=/usr/local/bin/IGV/:$PATH

# supporting UTF-8
RUN locale-gen "en_US.UTF-8" && update-locale LC_ALL="en_US.UTF-8"
ENV LC_ALL=en_US.UTF-8

CMD ["bash"]
