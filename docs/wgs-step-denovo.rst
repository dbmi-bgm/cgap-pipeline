=========================
Calling de novo mutations
=========================

This step uses granite novoCaller to call de novo mutations by assigning a posterior probability based on unrelated samples and trio. The output vcf file is checked for integrity to ensure the format is correct and the file is not truncated.

* CWL: workflow_granite-novoCaller-rck_plus_vcf-integrity-check.cwl


Requirements
++++++++++++

The proband must have two parents (may have additional samples) in the VCF. The step requires two .rck.tar files, one from the trio and one from a panel of unrelated individuals. A .rck.tar file is a tarball of .rck files that are created from bam files to record allele-specific and strand-specific read counts.


Output
++++++

The step creates an output VCF file that has the same entries from the input VCF file (no line is removed), but with additional information.

An example line in an output VCF looks as below:

::

    chr1  1041200 .    C    T    573.12 .    AC=2;AF=0.333;AN=6;BaseQRankSum=0.408;DP=76;ExcessHet=3.01;FS=3.873;MLEAC=2;MLEAF=0.333;MQ=60.00;MQRankSum=0.00;QD=13.65;ReadPosRankSum=0.155;SOR=1.877;gnomADgenome=7.00849e-06;SpliceAI=0.11;VEP=ENSG00000188157|ENST00000379370|Transcript|missense_variant|AGRN|protein_coding;novoPP=0.0  GT:AD:DP:GQ:PL:RSTR   0/1:9,4:13:99:100,0,248:6,5,4,2 0/0:34,0:34:96:0,96,1440:23,0,11,0   0/1:12,17:29:99:484,0,309:12,17,2,4   ./.:.:.:.:.:29,0,20,0  ./.:.:.:.:.:19,0,16,0  ./.:.:.:.:.:16,1,22,0  ./.:.:.:.:.:21,0,18,0  ./.:.:.:.:.:28,0,22,0  ./.:.:.:.:.:20,0,24,0  ./.:.:.:.:.:21,0,26,0  ./.:.:.:.:.:11,0,11,0  ./.:.:.:.:.:15,0,13,0  ./.:.:.:.:.:29,0,22,0


NovoPP
------

The output VCF contains NovoPP (0 <= NovoPP <= 1) assigned to the proband sample field. The NovoPP value indicates the posterior probability that the given variant is a de novo mutation. A high NovoPP value suggests that the variant is likely to be a de novo mutation. 


RSTR
----

The output VCF also contains sample fields for the panel of unrelated samples. These fields only contain RSTR tags in the format of ``Rf,Af,Rr,Ar`` (R: ref, A: alt, f: forward, r: reverse) (e.g. ``16,7,25,0``). The RSTR tag is also added to the sample fields of the trio samples.


FAQ
+++

1. Does this step handle both SNVs and indels?

  | Yes


2. What does NovoPP=0 mean?

  | NovoPP=0 means that the parents had 3 or more ALT reads and the posterior probability was not calculated. It means that the variant is highly unlikely to be a de novo mutation.

 
3. How does it work for chrX, Y, or M?

  | Currently we do not report NovoPP for chrX, Y, or M, except when NovoPP=0. This is because the model assumed by NovoCaller does not fit well with these chromosomes.


4. Does it take BAM files instead of .rck.tar files?

  | No.


