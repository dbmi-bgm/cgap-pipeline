===============
HaplotypeCaller
===============

This step uses ``GATK HaplotypeCaller`` to create a ``g.vcf`` file from the input bam file for Whole Genome Sequencing (WGS) data. If Whole Exome Sequencing (WES) data is provided, the ``HaplotypeCaller Exome`` step is run instead.

* CWL: gatk-HaplotypeCaller.cwl

**HaplotypeCaller for Exome**

This step uses ``GATK HaplotypeCaller`` to create a ``g.vcf`` file from the input bam file for WES data. This makes use of a permissive region of interest file we created for hg38 including all exons and UTR regions (see: https://cgap-annotations.readthedocs.io/en/latest/exome_regions.html). Use of a region file like this one follows GATK best practices for WES analysis (see: https://www.intel.com/content/dam/www/public/us/en/documents/white-papers/deploying-gatk-best-practices-paper.pdf). If WGS data is provided, the ``HaplotypeCaller`` step is run instead.

* CWL: gatk-HaplotypeCaller_exome.cwl
