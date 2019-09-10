# CGAP upstream pipeline

* Currently docker image `cgap/cgap:v9`


## alignment
  * CWL: workflow_bwa-mem-to-bam_no_unzip_plus_integrity-check.cwl

## add readgroups
  * CWL: workflow_add-readgroups_plus_integrity-check.cwl

## merge bams
  * CWL: workflow_merge-bam_plus_integrity-check.cwl

## mark duplicates
  * CWL: workflow_picard-MarkDuplicates_plus_integrity-check.cwl

## sort
  * CWL: workflow_sort-bam_plus_integrity-check.cwl

## BQSR report
  * CWL: gatk-BaseRecalibrator.cwl

## applyBQSR & indexing
  * CWL: workflow_gatk-ApplyBQSR_plus_integrity-check.cwl

