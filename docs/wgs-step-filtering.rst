==================
Filtering Variants
==================

This step performs filtering of the variants.

* CWL: workflow_granite-filtering_plus_vcf-integrity-check.cwl


Requirements
++++++++++++

A single, micro-annotated VCF file is an input. The micro-annotation should include annotation of VEP, CLINVAR and SpliceAI.

This step also requires a panel of unrelated samples in the .big format.


Steps
+++++

The filtering step is composed of multiple steps and the output vcf file is checked for integrity to ensure the format is correct and the file is not truncated.

.. image:: images/cgap_filtering_v14.png

Whitelist
---------

The whitelist steps use ``granite witheList`` to filter-in exonic and functionally relevant variant based on VEP, CLINVAR and SpliceAI annotations. The CLINVAR whitelist was performed separately so that the result does not undergo VEP cleaning and filtering by blacklist.


VEP cleaning
------------

This step uses ``granite cleanVCF`` to clean VEP annotations.


Blacklist
---------

The blacklist step uses ``granite blackList`` to filter-out common and shared variant based on gnomAD population allele frequency and a panel of unrelated samples. The panel of unrelated samples is in the .big format that contains the binary data (1: to be filtered, 0: not to be filetered) for every genomic position.


Merging
-------

The CLINVAR whitelist result is merged with the rest of the filtering result. For variants that overlap between the two, the CLINVAR entry is chosen to preserve the entry without VEP cleaning for CLINVAR variants.


Output
++++++

The output is a filtered VCF file containing a lot fewer entries compared to the input VCF. The content of the remaining entries are identical to the input (no additional information added) except the VEP annotation has been cleaned up to remove irrelevant consequences.

