=========
Alignment
=========

This step uses ``bwa mem`` to align a set of fastq reads to the genome reference. The output bam file is checked for integrity to ensure the file has a header and it is not truncated.

* CWL: workflow_bwa-mem-to-bam_no_unzip_plus_integrity-check.cwl

