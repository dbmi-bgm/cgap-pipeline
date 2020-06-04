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
    yasm

WORKDIR /usr/local/bin

# gatk4 & picard & python libraries
RUN conda install -c bioconda -y gatk4==4.1.2.0 picard==2.20.2 \
    pysam==0.15.3 bitarray==1.2.1 pytabix==0.0.2 h5py==2.10.0 numpy==1.18.1 pyfaidx==0.5.8 python=3.6.8 && \
    conda clean -a -y -f

# samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 && \
    tar -xjf samtools-1.9.tar.bz2 && \
    rm -rf samtools-1.9.tar.bz2 && \
    cd samtools-1.9 && \
    ./configure && \
    make && \
    cd .. && \
    ln -s samtools-1.9 samtools

# bwa
RUN wget https://github.com/lh3/bwa/archive/v0.7.17.tar.gz && \
    tar -xzf v0.7.17.tar.gz && \
    rm -rf v0.7.17.tar.gz && \
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

# pigz
RUN wget https://zlib.net/pigz/pigz-2.4.tar.gz && \
    tar -xzf pigz-2.4.tar.gz && \
    rm -rf pigz-2.4.tar.gz && \
    cd pigz-2.4 && \
    make && \
    cd ..

# pbgzip
RUN git clone https://github.com/nh13/pbgzip && \
    mv pbgzip pbgzip-dir && \
    cd pbgzip-dir && \
    git checkout 2b09f97 && \
    cd igzip && \
    make && \
    make install && \
    cd .. && \
    sh autogen.sh && \
    ./configure --enable-igzip && \
    make && \
    make install && \
    cd ..

# bwa mem script
COPY bwa-mem-to-bam.sh .
RUN chmod +x bwa-mem-to-bam.sh

COPY bwa-mem-to-bam_no_unzip.sh .
RUN chmod +x bwa-mem-to-bam_no_unzip.sh

# bam integrity check script
COPY integrity-check.sh .
RUN chmod +x integrity-check.sh

# vcf integrity check script
COPY vcf-integrity-check.sh .
RUN chmod +x vcf-integrity-check.sh

# add read groups script
RUN git clone https://github.com/dbmi-bgm/cgap-scripts/ && \
    cd cgap-scripts && \
    git checkout 41489dd && \
    chmod +x AddReadGroups.py && \
    chmod +x duplines_vcf.py && \
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

# granite
RUN git clone https://github.com/dbmi-bgm/granite.git && \
    cd granite && \
    git checkout a4f81ae && \
    rm -rf tests && \
    python setup.py install && \
    cd ..

# mpileupCounts parallel script
RUN mv granite/docker/mpileupCounts-parallel.sh . && \
    chmod +x mpileupCounts-parallel.sh

# mutanno
RUN git clone https://github.com/dbmi-bgm/mutanno.git && \
    cd mutanno && \
    git checkout 9583985 && \
    python setup.py install && \
    cd ..

# annot parallel script
COPY annot-parallel.sh .
RUN chmod +x annot-parallel.sh

# annot parallel mti script
COPY annot-parallel-mti.sh .
RUN chmod +x annot-parallel-mti.sh

# tar novoCaller script
COPY tar-novoCaller.sh .
RUN chmod +x tar-novoCaller.sh

# merge vcf script
COPY merge-sort-vcf.sh .
RUN chmod +x merge-sort-vcf.sh

# cramtools
RUN git clone https://github.com/enasequence/cramtools && \
    cd cramtools && \
    git checkout 0b5c9ec && \
    cd ..
COPY md5_to_fasta.py .
COPY cram_to_fastq.sh .
COPY cram_to_bam.sh .
RUN chmod +x cram_to_fastq.sh
RUN chmod +x cram_to_bam.sh

# env paths
ENV PATH=/usr/local/bin/samtools/:$PATH
ENV PATH=/usr/local/bin/bwa/:$PATH
ENV PATH=/usr/local/bin/cgap-scripts/:$PATH
ENV PATH=/usr/local/bin/pigz-2.4/:$PATH
ENV PATH=/usr/local/bin/granite/:$PATH
ENV PATH=/usr/local/bin/mutanno/:$PATH

# supporting UTF-8
RUN locale-gen "en_US.UTF-8" && update-locale LC_ALL="en_US.UTF-8"
ENV LC_ALL=en_US.UTF-8

CMD ["bash"]
