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

    comHet=Phased|ENSG00000084636|ENST00000373672~ENST00000488897|STRONG_PAIR|STROING_PAIR|chr1:31662352G>A


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


    1. If the VEP impact of both variants are HIGH ('H') or MODERATE ('M') or spliceAI score >0.8 ('S') or ClinVar Pathogenic or Likely Pathogenic ('C'), the impact of the pair is STRONG_PAIR.

    2. If one of the variants are H, M, S or C, the impact of the pair is MEDIUM_PAIR.

    3. If the variants do not satisfy the above criteria, the impact of the pair is WEAK_PAIR.


The impact is computed either at the gene level (gene impact) or at the transcript level (transcript impact).


Report
++++++

This step also generates a report that provides additional information on the compound heterozygous pairs that are called. The report contains statistics on the total number of pairs and their distribution by genes, transcripts, and predicted impact.


By genes
--------

For each gene, the program reports the number of compound het pairs called for the gene (``name``), together with the number of transcripts and variants involved.
In each category, it is reported the total number of elements that are involved in a compound het pair, as well as the total number of elements involved in a pair that is also phased.

::

    "by_genes": [
      {
        "name": "ENSG00000004455",
        "pairs": {
            "phased": 0,
            "total": 1
        },
        "transcripts": {
            "phased": 0,
            "total": 11
        },
        "variants": {
            "phased": 0,
            "total": 2
        }
      },
      ...
    ]


By transcripts
--------------

For each transcript, the program reports the number of compound het pairs called for the transcript (``name``), together with the number of variants involved and the gene to which the transcript belongs.
In each category, it is reported the total number of elements that are involved in a compound het pair, as well as the total number of elements involved in a pair that is also phased.

::

    "by_transcripts": [
      {
        "name": "ENST00000218200",
        "gene": "ENSG00000102081",
        "pairs": {
           "phased": 3,
           "total": 6
        },
        "variants": {
           "phased": 4,
           "total": 4
        }
      },
      ...
    ]


By impact
--------

For each impact, the program reports the number of compound het pairs predicted with that impact (``name``) as the worst possible impact, together with the number of genes, transcripts and variants involved.
In each category, it is reported the total number of elements that are involved in a compound het pair, as well as the total number of elements involved in a pair that is also phased.

::

    "by_impact": [
        {
          "name": "MEDIUM_PAIR",
          "pairs": {
              "phased": 28,
              "total": 44
          },
          "genes": {
              "phased": 23,
              "total": 34
          },
          "transcripts": {
              "phased": 55,
              "total": 81
          },
          "variants": {
              "phased": 51,
              "total": 78
          }
        },
        ...
      ]
