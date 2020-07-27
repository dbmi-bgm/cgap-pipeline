=====================
Apply BQSR & Indexing
=====================

This step uses ``GATK ApplyBQSR`` to apply a base quality score recalibration report to the input bam file. This step creates a recalibrated bam file and its index. The output bam file is checked for integrity to ensure the file has a header and it is not truncated.

* CWL: workflow_gatk-ApplyBQSR_plus_integrity-check.cwl

