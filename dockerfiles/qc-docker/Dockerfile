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
    zip \
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

# gatk4 & picard & python libraries
RUN conda install -c bioconda -y gatk4==4.1.2.0 picard==2.20.2 \
    pysam==0.15.3 bitarray==1.2.1 pytabix==0.0.2 h5py==2.10.0 numpy==1.18.1 pyfaidx==0.5.8 python=3.6.8 \
    peddy=0.4.7 && \
    conda clean -a -y -f

# granite
RUN pip install granite-suite==0.1.7

# samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 && \
    tar -xjf samtools-1.9.tar.bz2 && \
    cd samtools-1.9 && \
    ./configure && \
    make && \
    cd .. && \
    ln -s samtools-1.9 samtools

# bamqc
COPY bamqc.py .

# ancestry
COPY peddy.sh .
RUN chmod +x peddy.sh

# paths
ENV PATH=/usr/local/bin/samtools/:$PATH
ENV PATH=/usr/local/bin/bedtools/bin/:$PATH

# supporting UTF-8
RUN locale-gen "en_US.UTF-8" && update-locale LC_ALL="en_US.UTF-8"
ENV LC_ALL=en_US.UTF-8

CMD ["bash"]
