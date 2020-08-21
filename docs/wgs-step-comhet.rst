=======================================
Calling compound heterozygous mutations
=======================================

This step uses ``granite comHet`` to call compound heterozygous mutations by genes and transcripts, assigning the associate risk based on available annotations. The output vcf file is checked for integrity to ensure the format is correct and the file is not truncated.

* CWL: workflow_granite-comHet_plus_vcf-integrity-check.cwl


Requirements
++++++++++++

The input VCF must have VEP annotations (VEP consequences, gene and transcript are required). If the VEP annotation includes VEP impact, the step uses it. If not, it uses an existing VEP table (https://m.ensembl.org/info/genome/variation/prediction/predicted_data.html).


Specifications
++++++++++++++

Gene Assignments
----------------

To determine compound heterozygous pairs, variants must be first assigned to genes. For consistent and inclusive gene assignment, we followed the rules described below:

  1. Since we do not include intronic variants in our filtered set, we also do not assign variants to a gene/transcript if the variant is in an intron of the gene/transcript except if the variant is either predicted by spliceAI to be potential splice variant or is a ClinVar variant.
  2. Since we do not include variants in an upstream/downstream region of a gene/transcript, we also do not assign variants to a gene/transcript if the variant is in an upstream/downstream region of the gene/transcript, except if the variant is a ClinVar variant.


.. image:: images/gene_assignment_v14.png


This gene assignment is ensured by first 'cleaning' the pre-existing VEP annotation according to spliceAI and ClinVar annotations. This VEP cleaning is performed during the Filtering step of the pipeline. The Compound Het calling step assumes that VEP annotation in the input VCF already reflects the above rules.


Output
++++++

The output VCF preserves the input VCF and adds information to variants that are potentially compound heterozygous (no lines are removed). This additional information is in the following format:

::

    comHet=<Phased_or_Unphased>|<gene_id>|<transcript_id>|<gene_impact_of_comphet_pair>|<transcript_impact_of_comphet_pair>|<mate_variant>


It looks as below for example:

::

    comHet=Phased|ENSG00000084636|ENST00000373672,ENST00000488897|STRONG_PAIR|STROING_PAIR|chr1:31662352G>A


The following header is added to the output VCF file.

::

    ##INFO=<ID=comHet,Number=.,Type=String,Description="Putative compound heterozygous pairs. Subembedded:'cmpHet':Format:'phase|gene|transcript|impact_gene|impact_transcript|mate_variant'">



Gene vs transcript
------------------

A compound het pair is defined for each pair of variants and for each gene. If a variant forms a compound het pair on two or more genes, the output will have two comHet entries. A compound het pair may not always be on the same transcript, and we list the shared transcripts for a given compound het. If the variant pair does not share any transcript, the `transcript` term will be blank.


Phase
-----

A compound het pair is either phased or unphased.


.. image:: images/comphet_phase.png


Impact
------

The impact of a compound heterozygous pair is determined as below:


    1. If the VEP impact of both variants are HIGH ('H') or MODERATE ('M') or spliceAI score >0.8 ('S') or Clinvar Pathogenic or Likely Pathogenic ('C'), the impact of the pair is STRONG_PAIR.

    2. If one of the variants are H, M, S or C, the impact of the pair is MEDIUM_PAIR.

    3. If the variants do not satisfy the above criteria, the impact of the pair is WEAK_PAIR.

 
The impact is computed either at the gene level (gene impact) or at the transcript level (transcript impact).

