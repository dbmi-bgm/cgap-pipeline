==================
Variant annotation
==================

This step splits multialleic variants, realigns indels, removes variants that do not meet a threshold read depth (DP) of 3 in at least one sample, and annotates variants for the input ``vcf`` file. ``bcftools`` is used for split and realignment, ``depth_filter.py`` (https://github.com/dbmi-bgm/cgap-annotations) is used to filter variants based on depth, and ``VEP`` (Variant Effect Predictor - https://useast.ensembl.org/info/docs/tools/vep/index.html) from the Ensemble v101 release is used for annotation along with several plug-ins.

Beginning in ``v23`` of cgap-pipeline, a small modification was made to the source code for the dbNSFP plugin to allow for annotation of additional nonsynonymous variants (including variants involved in splicing).

For more details, see https://cgap-annotations.readthedocs.io/en/latest/variants_sources.html#vep

* CWL: workflow_vep-annot_plus_vcf-integrity-check.cwl
