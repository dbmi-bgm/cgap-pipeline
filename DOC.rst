CGAP WGS Pipeline
======================

CGAP WGS pipeline allows to process Whole Genome Sequencing data starting from fastq files and produce ``bam``, ``g.vcf`` and ``vcf`` files as output.

The pipeline is designed for trio analysis with proband diagnosed with a likely monogenic disease. It is optimized for data with 30x coverage and has been tested with data up to 80-90x coverage.

The pipeline is mostly based on ``bwa``, ``gatk4`` and ``granite`` (https://github.com/dbmi-bgm/granite). The pipeline only perform joint-sample variant calling within a family.


Docker Image
############

* Current docker image is ``cgap/cgap:v13``

The image contains (but is not limited to) the following software packages:

- gatk4 4.1.2.0
- picard 2.20.2
- bwa 0.7.17
- samtools 1.9
- parallel
- granite (e1f8aa3)
- mutanno (8a780bd)


Pipeline Steps
##############

Alignment
+++++++++

This step uses ``bwa mem`` to align a set of fastq reads to the genome reference.
The output bam file is checked for integrity to ensure the file has a header and it is not truncated.

* CWL: workflow_bwa-mem-to-bam_no_unzip_plus_integrity-check.cwl

Read Groups
+++++++++++

This step uses ``AddReadGroups.py`` (https://github.com/dbmi-bgm/cgap-scripts) to add read groups information to the input bam file, according to lanes and flowcells.
The script parses the bam file that contains a mix of multiple lanes and flowcells, extracts this information from read headers and adds the proper read group to individual reads, unlike ``picard AddOrReplaceReadGroups`` which assumes a single read group throughout the file.
The output bam file is checked for integrity to ensure the file has a header and it is not truncated.

* CWL: workflow_add-readgroups_plus_integrity-check.cwl

Merge
+++++

This step uses ``samtools merge`` to merge multiple bam files when data comes in multiple replicates.
If there are no replicates, this step is skipped.
The output bam file is checked for integrity to ensure the file has a header and it is not truncated.

* CWL: workflow_merge-bam_plus_integrity-check.cwl

Mark Duplicates
+++++++++++++++

This step uses ``picard MarkDuplicates`` to detect and mark PCR duplicates. It creates a duplicate-marked bam file and a report with duplicate stats.
The output bam file is checked for integrity to ensure the file has a header and it is not truncated.

* CWL: workflow_picard-MarkDuplicates_plus_integrity-check.cwl

Sort
++++

This step uses ``samtools sort`` to sort the input bam file by genomic coordinates.
The output bam file is checked for integrity to ensure the file has a header and it is not truncated.

* CWL: workflow_sort-bam_plus_integrity-check.cwl

Base Recalibration Report (BQSR)
+++++++++++++++++++++++++++++++++++++++++++

This step uses ``GATK BaseRecalibrator`` to create a base quality score recalibration report for the input bam file.

* CWL: gatk-BaseRecalibrator.cwl

Apply BQSR & Indexing
+++++++++++++++++++++

This step uses ``GATK ApplyBQSR`` to apply a base quality score recalibration report to the input bam file.
This step creates the final bam file and its index.
The output bam file is checked for integrity to ensure the file has a header and it is not truncated.

* CWL: workflow_gatk-ApplyBQSR_plus_integrity-check.cwl

HaplotypeCaller
+++++++++++++++

This step uses ``GATK HaplotypeCaller`` to create a g.vcf file from the input bam file.

* CWL: gatk-HaplotypeCaller.cwl

CombineGVCFs
++++++++++++

This step uses ``GATK CombineGVCFs`` to merge multiple g.vcf files to jointly call variants.

* CWL: gatk-CombineGVCFs.cwl

GenotypeGVCF
++++++++++++

This step uses ``GATK GenotypeGVCF`` to create a vcf file from a g.vcf file.
The output vcf file is checked for integrity to ensure the format is correct and the file not truncated.

* CWL: workflow_gatk-GenotypeGVCFs_plus_vcf-integrity-check.cwl

VariantRecalibrator (VQSR)
++++++++++++++++++++++++++

This step uses ``GATK VariantRecalibrator`` to recalibrate the quality score for the variants that are called.

* CWL: workflow_gatk-VQSR_plus_vcf-integrity-check.cwl

Micro Annotation
++++++++++++++++++++++++++

This step uses ``mutanno annot`` to minimally annotate the input vcf with VEP, CLINVAR and SpliceAI information.
The output vcf file is checked for integrity to ensure the format is correct and the file not truncated.

* CWL: workflow_mutanno-micro-annot-check.cwl

White List
++++++++++++++++++++++++++

This step uses ``granite witheList`` to filter-in exonic and functionally relevant variant based on VEP, CLINVAR and SpliceAI annotations.
The output vcf file is checked for integrity to ensure the format is correct and the file not truncated.

* CWL: workflow_granite-whiteList-check.cwl

Black List
++++++++++++++++++++++++++

This step uses ``granite blackList`` to filter-out common and shared variant based on population allele frequency and jointly-called unrelated samples.
The output vcf file is checked for integrity to ensure the format is correct and the file not truncated.

* CWL: workflow_granite-blackList-check.cwl

De Novo Calling
++++++++++++++++++++++++++

This step uses ``granite novoCaller`` to call *de novo* mutations assigning a posterior probability based on unrelated samples and trio.
The output vcf file is checked for integrity to ensure the format is correct and the file not truncated.

* CWL: workflow_granite-novoCaller-rck-check.cwl

Full Annotation
++++++++++++++++++++++++++

This step uses ``mutanno annot`` to fully annotate a vcf.
The output vcf file is checked for integrity to ensure the format is correct and the file not truncated.

* CWL: workflow_mutanno-annot-check.cwl
