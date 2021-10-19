======================================================
Part 1. GATK Best Practice Mapping and Variant Calling
======================================================

Alignment
+++++++++

This step uses ``bwa mem`` to align a set of fastq reads to the genome reference. The ``bwa mem`` step was updated in ``v24`` to use additional index files for alternative contigs. This procedure is described for GRCH38 here (https://gatk.broadinstitute.org/hc/en-us/articles/360037498992) and the 6 reference files ``Homo_sapiens_assembly38.fasta.64.xxx`` were downloaded from here (https://console.cloud.google.com/storage/browser/genomics-public-data/resources/broad/hg38/v0).
The output bam file is checked for integrity to ensure the file has a header and it is not truncated.

* CWL: workflow_bwa-mem-to-bam_no_unzip_plus_integrity-check.cwl

Add read groups
+++++++++++++++

This step uses ``AddReadGroups.py`` (https://github.com/dbmi-bgm/cgap-scripts) to add read groups information to the input bam file, according to lanes and flowcells.
The script parses the bam file that contains a mix of multiple lanes and flowcells, extracts this information from read headers and adds the proper read group to individual reads, unlike ``picard AddOrReplaceReadGroups`` which assumes a single read group throughout the file.
The output bam file is checked for integrity to ensure the file has a header and it is not truncated.

* CWL: workflow_add-readgroups_plus_integrity-check.cwl

Merge bams
++++++++++

This step uses ``samtools merge`` to merge multiple bam files when data comes in multiple replicates.
If there are no replicates, this step is skipped.
The output bam file is checked for integrity to ensure the file has a header and it is not truncated.

* CWL: workflow_merge-bam_plus_integrity-check.cwl

Mark duplicates
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

Apply BQSR & indexing
+++++++++++++++++++++

This step uses ``GATK ApplyBQSR`` to apply a base quality score recalibration report to the input bam file.
This step creates a recalibrated bam file and its index.
The output bam file is checked for integrity to ensure the file has a header and it is not truncated.

* CWL: workflow_gatk-ApplyBQSR_plus_integrity-check.cwl
