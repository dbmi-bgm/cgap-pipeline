=============
Mpileup count
=============

This step creates a ``.rck`` (Read Count Keeper) file from a BAM file. This is a pre-requisite step for calling de novo mutations.

* CWL: granite-mpileupCounts.cwl


Requirements
++++++++++++

A BAM file and a reference ``fasta`` file must be provided. The step also takes in a file containing a list of genomic regions (that collectively covers the whole genome), to specify regions to run in parallel.


Output
++++++

The output ``.rck`` file contains read pileup count information for every genomic position, stratified by allele (REF vs ALT), strand (Forward vs Reverse), and type (SNV, Insertion, Deletion).


A few lines from an example ``.rck`` file is shown below:

::

  #CHR   POS   COVERAGE   REF_FW   REF_RV   ALT_FW   ALT_RV   INS_FW   INS_RV   DEL_FW   DEL_REV
  13     1     23         0        0        11       12       0        0        0        0
  13     2     35         18       15       1        1        0        0        0        0

A ``.rck`` file is a tab-delimited text file and is tabix-indexed.
