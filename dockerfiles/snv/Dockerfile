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
    autotools-dev \
    automake \
    pkg-config \
    tabix \
    yasm \
    libdbi-perl \
    libmodule-build-perl \
    libarchive-zip-perl \
    libmysqlclient-dev \
    libpng-dev \
    libexpat1-dev

WORKDIR /usr/local/bin

# gatk4 & picard & python libraries
RUN conda install -c bioconda -y gatk4==4.1.2.0 picard==2.20.2 \
    pysam==0.15.3 bitarray==1.2.1 pytabix==0.0.2 h5py==2.10.0 numpy==1.18.1 pyfaidx==0.5.8 tqdm==4.48.2 pyliftover==0.4 python=3.6.8 peddy==0.4.7 && \
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

# bcftools
RUN wget https://github.com/samtools/bcftools/releases/download/1.11/bcftools-1.11.tar.bz2 && \
    tar -xjf bcftools-1.11.tar.bz2 && \
    rm -rf bcftools-1.11.tar.bz2 && \
    cd bcftools-1.11 && \
    ./configure && \
    make && \
    cd .. && \
    ln -s bcftools-1.11 bcftools

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

# cramtools
RUN git clone https://github.com/enasequence/cramtools && \
    cd cramtools && \
    git checkout 0b5c9ec && \
    cd ..

# pigz
RUN wget https://zlib.net/pigz/pigz-2.6.tar.gz && \
    tar -xzf pigz-2.6.tar.gz && \
    rm -rf pigz-2.6.tar.gz && \
    cd pigz-2.6 && \
    make && \
    cd .. && \
    ln -s pigz-2.6 pigz

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
    cd .. && \
    rm -rf pbgzip-dir

ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# VEP
RUN git clone https://github.com/Ensembl/ensembl-vep.git && \
    cd ensembl-vep && \
    git checkout release/101 && \
    perl INSTALL.pl --AUTO a --NO_UPDATE && \
    cd ..

# perl module for VEP
RUN cpan App::cpanminus && \
    wget https://github.com/ucscGenomeBrowser/kent/archive/v335_base.tar.gz && \
    tar xzf v335_base.tar.gz && \
    export KENT_SRC=/usr/local/bin/kent-335_base/src && \
    export MACHTYPE=$(uname -m) && \
    export CFLAGS="-fPIC" && \
    export MYSQLINC=`mysql_config --include | sed -e 's/^-I//g'` && \
    MYSQLLIBS=`mysql_config --libs` && \
    export MYSQLLIBS && \
    cd $KENT_SRC/lib && \
    echo 'CFLAGS="-fPIC"' > ../inc/localEnvironment.mk && \
    make clean && make && \
    cd ../jkOwnLib && \
    make clean && make && \
    cd /usr/local/bin/ && \
    mkdir -p /usr/local/bin/cpanm_bw && \
    export PERL5LIB=$PERL5LIB:/usr/local/bin/cpanm_bw/lib/perl5 && \
    cpanm -l /usr/local/bin/cpanm_bw Bio::DB::BigFile && \
    rm -f v335_base.tar.gz && \
    rm -rf kent-335_base/ && \
    cd /usr/local/bin/ensembl-vep && \
    perl -Imodules t/AnnotationSource_File_BigWig.t && \
    cd /usr/local/bin

ENV PERL5LIB=$PERL5LIB:/usr/local/bin/cpanm_bw/lib/perl5

# VEP script
COPY vep-annot.sh .
RUN chmod +x vep-annot.sh

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

# sort bgzip-index vcf
COPY sort-bgzip-vcf.sh .
RUN chmod +x sort-bgzip-vcf.sh

# add read groups script
RUN git clone https://github.com/dbmi-bgm/cgap-scripts/ && \
    cd cgap-scripts && \
    git checkout 28520db && \
    chmod +x AddReadGroups.py && \
    chmod +x duplines_vcf.py && \
    chmod +x samplegeno.py && \
    chmod +x split_bam.py && \
    cd ..

# add cgap-annotations scripts - dbSNP ID, hgvsg, liftover_hg19, depth_filter
RUN git clone https://github.com/dbmi-bgm/cgap-annotations.git && \
    cd cgap-annotations && \
    git checkout 7a5fb7b && \
    cd .. && \
    cp cgap-annotations/variants/scripts/hgvsg_creator.py . && \
    chmod +x hgvsg_creator.py && \
    cp cgap-annotations/variants/scripts/liftover_hg19.py . && \
    chmod +x liftover_hg19.py && \
    cd cgap-annotations && \
    git checkout 2a9b3d7 && \
    cd .. && \
    cp cgap-annotations/variants/scripts/dbSNP_ID_fixer.py . && \
    chmod +x dbSNP_ID_fixer.py && \
    cd cgap-annotations && \
    git checkout 7776a34 && \
    cd .. && \
    cp cgap-annotations/variants/scripts/depth_filter.py . && \
    chmod +x depth_filter.py && \
    rm -rf cgap-annotations

# HaplotypeCaller parallel script
COPY HaplotypeCaller-parallel.sh .
RUN chmod +x HaplotypeCaller-parallel.sh

# HaplotypeCaller script
COPY HaplotypeCaller.sh .
RUN chmod +x HaplotypeCaller.sh

# CombineGVCFs parallel script
COPY CombineGVCFs-parallel.sh .
RUN chmod +x CombineGVCFs-parallel.sh

# GenotypeGVCFs parallel script
COPY GenotypeGVCFs-parallel.sh .
RUN chmod +x GenotypeGVCFs-parallel.sh

# cram2fastq, cram2bam scripts
COPY md5_to_fasta.py .
COPY cram_to_fastq.sh .
COPY cram_to_bam.sh .
COPY bam_to_fastq.sh .
RUN chmod +x cram_to_fastq.sh
RUN chmod +x cram_to_bam.sh
RUN chmod +x bam_to_fastq.sh

# granite
RUN pip install granite-suite==0.1.12

# mpileupCounts parallel script
RUN wget https://raw.githubusercontent.com/dbmi-bgm/granite/master/docker/mpileupCounts-parallel.sh && \
    chmod +x mpileupCounts-parallel.sh

# bamsnap
RUN pip install bamsnap-cgap==0.3.0

# tar novoCaller script
COPY tar-novoCaller.sh .
RUN chmod +x tar-novoCaller.sh

# merge vcf script
COPY merge-sort-vcf.sh .
RUN chmod +x merge-sort-vcf.sh

# bcftools norm multiallelics
COPY bcftools-norm-multiallelics.sh .
RUN chmod +x bcftools-norm-multiallelics.sh

# samplegeno
COPY samplegeno.sh .
RUN chmod +x samplegeno.sh

# dbSNP ID fix
COPY parallel_dbSNP_ID_fixer.sh .
RUN chmod +x parallel_dbSNP_ID_fixer.sh

# bamqc
COPY bamqc.py .

# peddy
COPY peddy.sh .
RUN chmod +x peddy.sh

# unique variants
COPY uniq_variants.sh .
RUN chmod +x uniq_variants.sh

# qc variant line count
COPY qc_variant_line_count.sh .
RUN chmod +x qc_variant_line_count.sh

# ApplyBQSR parallel
COPY ApplyBQSR-parallel.sh .
RUN chmod +x ApplyBQSR-parallel.sh

# env paths
ENV PATH=/usr/local/bin/samtools/:$PATH
ENV PATH=/usr/local/bin/bcftools/:$PATH
ENV PATH=/usr/local/bin/bwa/:$PATH
ENV PATH=/usr/local/bin/cgap-scripts/:$PATH
ENV PATH=/usr/local/bin/pigz/:$PATH
ENV PATH=/usr/local/bin/ensembl-vep/:$PATH

# supporting UTF-8
RUN locale-gen "en_US.UTF-8" && update-locale LC_ALL="en_US.UTF-8"
ENV LC_ALL=en_US.UTF-8

CMD ["bash"]
