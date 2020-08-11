===================
VCF Quality Control
===================

To evaluate quality of a VCF file, different metrics are calculated using ``granite qcVCF``.

granite qcVCF
+++++++++++++

The program calculates both sample-based, as well as, family-based metrics.

The metrics currently available for sample are:

  - variant types distribution
  - base substitutions
  - transition-transversion ratio
  - heterozygosity ratio
  - depth of coverage (GATK)
  - depth of coverage (raw from bam)

The metrics currently available for family are:

  - mendelian errors in trio
