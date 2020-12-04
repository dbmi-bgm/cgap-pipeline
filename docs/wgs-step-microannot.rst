================
Micro-Annotation
================

This step uses ``mutanno annot`` to minimally annotate the input vcf with gnomAD, VEP, ClinVar and SpliceAI information. The output vcf file is checked for integrity to ensure the format is correct and the file is not truncated.

* CWL: workflow_mutanno-micro-annot_plus_vcf-integrity-check.cwl
