CGAP upstream pipeline
======================

The CGAP Upstream pipeline processes Whole Genome Sequencing data (optimized for 30x), starting from a set of fastq files and producing ``bam``, ``gvcf`` and ``vcf`` files. The pipeline is mostly based on ``bwa`` and ``gatk4``. This pipeline does *not* perform joint-sample variant calling, and is meant for a single sample data.


Docker image
############

* Currently docker image ``cgap/cgap:v10``

The image contains but (is not limited to) the following software packages:

- gatk4 4.1.2.0
- picard 2.20.2
- bwa 0.7.17
- samtools 1.9
- parallel

Pipeline Steps
##############

Alignment
+++++++++

Alignment of fastq reads to the genome reference using ``bwa mem``. A quick bam integrity check step is added to ensure the final bam file has a header and is not truncated.

* CWL: workflow_bwa-mem-to-bam_no_unzip_plus_integrity-check.cwl


Add readgroups
++++++++++++++

This step adds read group information to the input bam file according to lane and flowcell, using our custom script ``AddReadGroups.py`` in https://github.com/dbmi-bgm/cgap-scripts. This script reads a bam file that contains a mix of multiple lanes and flowcells, extracts this information from the read headers and adds proper read group to the individual reads, unlike ``picard AddOrReplaceReadGroups`` which assumes a single read group throughout a given bam file.

A quick bam integrity check step is added to ensure the final bam file has a header and is not truncated.

* CWL: workflow_add-readgroups_plus_integrity-check.cwl


Merge bams
++++++++++

This step merges multiple bam files using ``samtools merge``, in case the data comes in multiple replicates. If there are no replicates, this step is skipped.

A quick bam integrity check step is added to ensure the final bam file has a header and is not truncated.


* CWL: workflow_merge-bam_plus_integrity-check.cwl


Mark duplicates
+++++++++++++++

This step detects and marks PCR duplicates, using ``picard MarkDuplicates``. It creates a duplicate-marke bam file and a report about duplicate stats.

A quick bam integrity check step is added to ensure the final bam file has a header and is not truncated.

* CWL: workflow_picard-MarkDuplicates_plus_integrity-check.cwl


Sort
++++

This step sorts the input bam file by genomic coordinates using ``samtools sort``.

A quick bam integrity check step is added to ensure the final bam file has a header and is not truncated.

* CWL: workflow_sort-bam_plus_integrity-check.cwl


Generate a base recalibration (BQSR) report
+++++++++++++++++++++++++++++++++++++++++++

This step creates a base quality score recalibration report for a given bam file, using ``GATK BaseRecalibrator``, taking into account various read group information.

* CWL: gatk-BaseRecalibrator.cwl


Apply BQSR & indexing
++++++++++++++++++++

This step applies a base quality score recalibration report to the input bam file, using ``GATK ApplyBQSR``. This step creates the final bam file and its index.

A quick bam integrity check step is added to ensure the final bam file has a header and is not truncated.

* CWL: workflow_gatk-ApplyBQSR_plus_integrity-check.cwl


HaplotypeCaller
+++++++++++++++

This step creates a GVCF file from the final bam file, using ``GATK HaplotypeCaller``.

* CWL: gatk-HaplotypeCaller.cwl


GenotypeGVCF
++++++++++++

This step creates a vcf file from a gvcf file, using ``GATK GenotypeGVCF``.

* CWL: gatk-GenotypeGVCFs.cwl

