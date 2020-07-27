===============
Mark Duplicates
===============

This step uses ``picard MarkDuplicates`` to detect and mark PCR duplicates. It creates a duplicate-marked bam file and a report with duplicate stats. The output bam file is checked for integrity to ensure the file has a header and it is not truncated.

* CWL: workflow_picard-MarkDuplicates_plus_integrity-check.cwl

