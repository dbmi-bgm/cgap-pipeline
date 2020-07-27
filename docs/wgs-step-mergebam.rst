=========
Merge Bam
=========

This step uses ``samtools merge`` to merge multiple bam files when data comes in multiple replicates. If there are no replicates, this step is skipped. The output bam file is checked for integrity to ensure the file has a header and it is not truncated.

* CWL: workflow_merge-bam_plus_integrity-check.cwl

