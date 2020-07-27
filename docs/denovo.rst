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

    chr1 225494089 . G A 58.93 . AC=4;AF=0.667;AN=6;BaseQRankSum=0.940;DP=63;ExcessHet=3.01;FS=10.488;MLEAC=3;MLEAF=0.500;MQ=59.60;MQRankSum=0.00;QD=1.18;ReadPosRankSum=0.768;SOR=3.191;SAMPLEGENO=0/1|G/A|18/6|NA12877_sample,1/1|A/A|0/0|NA12878_sample,0/1|G/A|23/3|NA12879_sample;gnomADgenome=5.56979e-03;SpliceAI=0.00;VEP=ENSG00000154380|ENST00000366844|Transcript|3_prime_UTR_variant|ENAH|protein_coding;novoPP=0.0GT:AD:DP:GQ:PGT:PID:PL:PS:RSTR 0/1:18,6:24:4:.:.:4,0,436:.:16,7,25,0 1/1:0,0:0:3:.:.:45,3,0:.:12,4,22,0 0|1:23,3:26:21:1|0:225494064_C_CA:21,0,940:225494064:22,5,27,1 ./.:.:.:.:.:.:.:.:9,1,8,0 ./.:.:.:.:.:.:.:.:12,0,21,0 ./.:.:.:.:.:.:.:.:14,1,19,0 ./.:.:.:.:.:.:.:.:24,0,21,0 ./.:.:.:.:.:.:.:.:30,1,29,0 ./.:.:.:.:.:.:.:.:20,0,21,0 ./.:.:.:.:.:.:.:.:25,0,26,0 ./.:.:.:.:.:.:.:.:18,0,28,0 ./.:.:.:.:.:.:.:.:9,1,27,0 ./.:.:.:.:.:.:.:.:10,0,15,0 ./.:.:.:.:.:.:.:.:11,1,16,0 ./.:.:.:.:.:.:.:.:17,0,17,0 ./.:.:.:.:.:.:.:.:24,3,17,0 ./.:.:.:.:.:.:.:.:19,1,18,0 ./.:.:.:.:.:.:.:.:28,0,14,0 ./.:.:.:.:.:.:.:.:26,0,19,1 ./.:.:.:.:.:.:.:.:32,0,18,0 ./.:.:.:.:.:.:.:.:30,0,27,0 ./.:.:.:.:.:.:.:.:21,0,22,0 ./.:.:.:.:.:.:.:.:15,1,15,0


NovoPP
------

The output VCF contains NovoPP (0 <= NovoPP <= 1) assigned to the proband sample field. The NovoPP value indicates the posterior probability that the given variant is a de novo mutation. A high NovoPP value suggests that the variant is likely to be a de novo mutation. 


RSTR
----

The output VCF also contains sample fields for the panel of unrelated samples. These fields only contain RSTR tags in the format of ``Rf,Af,Rr,Ar`` (R: ref, A: alt, f: forward, r: reverse) (e.g. ``16,7,25,0``). The RSTR tag is also added to the sample fields of the trio samples.


FAQ
+++

1. Does this step handle both SNVs and indels?

::

    Yes


2. What does NovoPP=0 mean?

::

    NovoPP=0 means that the parents had 3 or more ALT reads and the posterior probability was not calculated. It means that the variant is highly unlikely to be a de novo mutation.

 
3. How does it work for chrX, Y, or M?

::

    Currently we do not report NovoPP for chrX, Y, or M, except when NovoPP=0. This is because the model assumed by NovoCaller does not fit well with these chromosomes.


4. Does it take BAM files instead of .rck.tar files?

::

     No.


