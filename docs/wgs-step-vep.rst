===================
Variants annotation
===================

This step splits multialleic variants, realigns indels, and annotates variants for the input vcf file. ``bcftools`` is used for split and realignment, VEP (Variant Effect Predictor) from the Ensemble (https://useast.ensembl.org/info/docs/tools/vep/index.html) v101 is used for annotation along with several plug-ins.
Beginning in v23 of cgap-pipeline, a small modification was made to the source code for the dbNSFP plugin to allow for annotation of non-missense variants.

For more details, see https://cgap-annotations.readthedocs.io/en/latest/variants_sources.html#vep

* CWL: workflow_vep-annot_plus_vcf-integrity-check.cwl
