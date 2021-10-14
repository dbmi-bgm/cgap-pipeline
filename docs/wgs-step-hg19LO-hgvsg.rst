===================================
hg19 LiftOver and hgvsg INFO fields
===================================

This step uses liftover_hg19.py and hgvsg_creator.py (both at https://github.com/dbmi-bgm/cgap-annotations) to add hg19 coordinates and hgvsg entries to qualifying variants from a filtered sample ``vcf`` file. The output ``vcf`` file is checked for integrity.

* CWL: workflow_hg19lo_hgvsg_plus_vcf-integrity-check.cwl

Requirements
++++++++++++

Must be run on sample ``vcf`` following bcftools norm since it only allows one variant per line in the sample ``vcf``.

Output
++++++

This step creates an output ``vcf`` file that has the same entries from the input ``vcf`` file (no line is removed), but with additional information.  Three lines are added to the header:

::

  ##INFO=<ID=hgvsg,Number=.,Type=String,Description="hgvsg created from variant following best practices - http://varnomen.hgvs.org/recommendations/DNA/">
  ##INFO=<ID=hg19_chr,Number=.,Type=String,Description="CHROM in hg19 using LiftOver from pyliftover">
  ##INFO=<ID=hg19_pos,Number=.,Type=Integer,Description="POS in hg19 using LiftOver from pyliftover (converted back to 1-based)">

The data associated with these tags are also added to the INFO field of the ``vcf`` for qualifying variants using the criteria outline below.

For hg19 LiftOver:

1. For the hg19 LiftOver, all variants with successful conversions will include data for both the ``hg19_chr=`` and ``hg19_pos=`` tags in the INFO field.  Failed conversions (e.g., coordinates that do not have a corresponding region in hg19) will not print the tags or any LiftOver data.
2. Given that pyliftover does not convert ranges, the single-point coordinate in hg38 corresponding to each variant's CHROM and POS are used as query, and the hg19 coordinate (result) will also be a single-point coordinate.

For hgvsg:

1. For hgvsg, best practices (http://varnomen.hgvs.org/recommendations/DNA/) were followed.  All variants on the 23 nuclear chromosomes receive a ``g.`` and all mitochondrial variants receive an ``m.``.
2. All variants should receive an ``hgvsg=`` tag within their INFO field with data pertaining to their chromosomal location and variant type.
3. If a variant on a contig (e.g., chr21_GL383580v2_alt) were to be included in the filtered ``vcf``, it would not receive an ``hgvsg=`` tag, or any hgvsg data, since contigs were not included in the python script's library of chromosomal conversions (e.g., chr1 is NC_000001.11).

For more details, see https://cgap-annotations.readthedocs.io/en/latest/variants_sources.html#hg19-liftover and https://cgap-annotations.readthedocs.io/en/latest/variants_sources.html#hgvsg
