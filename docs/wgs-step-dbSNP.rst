=================
dbSNP rsID update
=================

This step uses ``parallel_dbSNP_ID_fixer.sh`` (https://github.com/dbmi-bgm/cgap-pipeline) to run ``dbSNP_ID_fixer.py`` (https://github.com/dbmi-bgm/cgap-annotations) and update dbSNP rsIDs in a sample VCF file's ID column. The output vcf file is checked for integrity.

* CWL: workflow_parallel_dbSNP_ID_fixer_plus_vcf-integrity-check.cwl

Requirements
++++++++++++

Must be run on sample VCF following bcftools norm since it only allows one variant per line in the sample VCF.

Output
++++++

This process follows the following rules:

  1. Variants in the sample VCF are matched to the reference dbSNP VCF by CHROM, POS, REF, and ALT columns.
  2. All rsIDs in the sample VCF ID column are discarded and replaced by whatever is found in the reference dbSNP VCF.
  3. Given a known bug where bcftools norm leaves an erroneous rsID at multiallelic sites, this will sometimes result in the removal of an rsID to be replaced by nothing ``.``.
  4. When multiple dbSNP rsIDs exist for a single CHROM, POS, REF, and ALT in the dbSNP reference VCF, we have chosen to include them all, each separated by ``;``.  In our analysis, we looked up numerous examples where there were multiple rsIDs that appeared to be for the same variant.  In some cases one had been chosen as a parent to which the others were merged, but in other cases, we found no link two rsIDs for variants that appear to be identical.  gnomAD from The Broad Institute (https://gnomad.broadinstitute.org/help) mentions similar issues with dbSNP within their database, so we have chosen to include all possible rsIDs for a given variant at this stage.
  5. If a sample VCF has a non-rsID within the ID field, this is not discarded. It will appear first in the ``;``-delimited list of any and all rsIDs found to match that variant in the reference dbSNP VCF.

An example of how these rules are followed with various inputs is found below:

.. image:: images/dbSNP_reference_table.png

For more details, see https://cgap-annotations.readthedocs.io/en/latest/variants_sources.html#dbsnp
