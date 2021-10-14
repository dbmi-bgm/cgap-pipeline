===============
Call validation
===============

For validation we are using a 3 generation family with children (C), parents (P), and grand-parents (GP).
The statistics are calculated using ``granite validateVCF`` command. Samples for all family members are necessary.

::

    GP1    GP2     GP3   GP4
      └──┬──┘       └──┬──┘
         P1            P2
         └──────┬──────┘
    ┌───┬───┬───┼───┬───┬───┐
    C1  C2  C3  C4  C5  C6  ..


GATK heterozygous calls
+++++++++++++++++++++++

Requirements:

  - ``vcf`` file with joint calls for all family members, family-VCF
  - ``vcf`` file with joint calls for trio (child and parents), trio-VCF
  - family pedigree files in json format, one for each parent

As a first step, we rename the samples in trio-VCF and merge trio-VCF to family-VCF using ``bcftools merge``.
We will use the calls for parents from the trio-VCF, since that is the strategy used by the pipeline.
``granite`` needs two pedigree files, one for each parent.
The sample name for each parent in the corresponding pedigree must match the one in trio-VCF for granite to use the right sample.

::

  granite validateVCF \
        -i merged.vcf \
        -p pedigree.P1.json pedigree.P2.json \
        -o output.json \
        --het samplename_P1 samplename_P2 \
        --anchor samplename_P1 samplename_P2

Example
::

  granite validateVCF \
        -i GAPFIR4IUBTH.merged.vcf \
        -p pedigree.UGRP1.5.json pedigree.UGRP1.6.json \
        -o UGRP1.het.vcf \
        --het UGRP1_ind_5_GAPFIR4IUBTH UGRP1_ind_6_GAPFIR4IUBTH \
        --anchor UGRP1_ind_5_GAPFIR4IUBTH UGRP1_ind_6_GAPFIR4IUBTH

The analysis is automated by the script ``het_stat.sh`` inside ``test/validation`` folder.
It will rename the samples, merge the files and run ``granite validateVCF``.
family-VCF requires the index file.

::

  het_stat.sh novo-VCF family-VCF pedigree.json samplename_P1 samplename_P2

Example

::

  het_stat.sh GAPFIR4IUBTH.vcf.gz GAPFII2XMRF5.vcf.gz pedigree.UGRP1.json UGRP1_ind_5 UGRP1_ind_6


novoCaller *de novo* calls (one child)
++++++++++++++++++++++++++++++++++++++
*note: a parent can be used instead of a child as well, same procedure*

| Requirements:

  - ``vcf`` file with joint calls for all family members, family-VCF
  - ``vcf`` file with joint calls for trio (child and parents) with novoCaller scores, novo-VCF.
  - family pedigree file in json format for the child

As a first step, we rename the samples in novo-VCF and merge novo-VCF to family-VCF using ``bcftools merge``.
We will use calls for the child from novo-VCF, since that is the strategy used by the pipeline.
``granite`` needs a pedigree file for the child.
The sample name for the child in pedigree must match the one in novo-VCF for granite to use the right sample.

::

  granite validateVCF \
        -i merged.vcf \
        -p pedigree.C.json \
        -o output.json \
        --novo samplename_C \
        --anchor samplename_C

The analysis is automated by the script ``denovo_stat.sh`` inside ``test/validation`` folder.
It will rename the samples, merge the files and run ``granite validateVCF`` for SNV and INDEL producing two separate outputs.
family-VCF requires the index file.

::

  denovo_stat.sh novo-VCF family-VCF pedigree.json samplename_C

Example

::

  denovo_stat.sh GAPFIR4IUBTH.vcf.gz GAPFII2XMRF5.vcf.gz pedigree.UGRP1.json UGRP1_ind_7
