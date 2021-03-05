===================
VCF Quality Control
===================

Overview
++++++++

To evaluate the quality of a VCF file, different metrics are calculated using ``granite qcVCF``.
The software calculates both sample-based, as well as, family-based metrics.

The metrics currently available for sample are:

  - variant types distribution
  - base substitutions
  - transition-transversion ratio
  - heterozygosity ratio
  - depth of coverage (GATK)
  - depth of coverage (raw)

The metrics currently available for family are:

  - mendelian errors in trio

For each sample, ancestry and sex are also predicted using ``peddy`` [1]_.
The predicted values allow to identify errors in sample labeling, contaminations events, and other errors that can occur during handling and processing of the sample.

Definitions
+++++++++++

variant types distribution
--------------------------

Total number of variants classified by type as:

  - **DEL**\ etion  (*ACTG>A or ACTG>\**)
  - **INS**\ ertion  (*A>ACTG or \*>ACTG*)
  - **S**\ ingle-\ **N**\ ucleotide **V**\ ariant  (*A>T*)
  - **M**\ ulti-\ **A**\ llelic **V**\ ariant  (*A>T,C*)
  - **M**\ ulti-\ **N**\ ucleotide **V**\ ariant  (*AA>TT*)

base substitutions
------------------

Total number of SNVs classified by the type of substitution (e.g. C>T).

transition-transversion ratio
-----------------------------

Ratio of transitions to transversions in SNVs.
It is expected to be [2, 2.20] for WGS and [2.6, 3.3] for WES.

heterozygosity ratio
--------------------

Ratio of heterozygous to alternate homozygous variants.
It is expected to be [1.5, 2.5] for WGS analysis.
Heterozygous and alternate homozygous sites are counted by variant type.

depth of coverage
-----------------

Average depth of all variant sites called in the sample.

Depth of coverage (GATK) is calculated based on DP values as assigned by GATK.
Depth of coverage (raw) is calculated based on raw read counts calculated directly from the bam file.

mendelian errors in trio
------------------------

Variant sites in proband that are not consistent with mendelian inheritance rules based on parent genotypes.
Mendelian errors are counted by variant type and classified based on genotype combinations in trio as:

+------------+------------+-----------+---------------------+
| Proband    | Father     | Mother    | Type                |
+============+============+===========+=====================+
| 0/1        | 0/0        | 0/0       | de novo             |
+------------+------------+-----------+---------------------+
| 0/1        | 1/1        | 1/1       | error               |
+------------+------------+-----------+---------------------+
| 1/1        | 0/0        | (any)     | error               |
+------------+------------+-----------+---------------------+
| 1/1        | (any)      | 0/0       | error               |
+------------+------------+-----------+---------------------+
| 1/1 \| 0/1 | ./.        | (any)     | missing in parent   |
+------------+------------+-----------+---------------------+
| 1/1 \| 0/1 | (any)      | ./.       | missing in parent   |
+------------+------------+-----------+---------------------+

ancestry and sex prediction
---------------------------

Ancestry prediction is based on projection onto the thousand genomes principal components.
Sex is predicted by using the genotypes observed outside the pseudo-autosomal region on X chromosome.

---------------------------

.. [1] Pedersen and Quinlan, Who’s Who? Detecting and Resolving Sample Anomalies in Human DNA Sequencing Studies with Peddy, The American Journal of Human Genetics (2017), http://dx.doi.org/10.1016/j.ajhg.2017.01.017
