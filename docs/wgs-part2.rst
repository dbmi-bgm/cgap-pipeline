=============================================
Part 2. GATK-based per-family variant calling
=============================================


CombineGVCFs
++++++++++++

This step uses ``GATK CombineGVCFs`` to merge multiple g.vcf files to jointly call variants.

* CWL: gatk-CombineGVCFs.cwl


GenotypeGVCF
++++++++++++

This step uses ``GATK GenotypeGVCF`` to create a vcf file from a g.vcf file.
The output vcf file is checked for integrity to ensure the format is correct and the file is not truncated.

* CWL: workflow_gatk-GenotypeGVCFs_plus_vcf-integrity-check.cwl

