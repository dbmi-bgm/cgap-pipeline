## CGAP pipeline
* This repo contains CGAP pipeline components
  * CWL
  * Docker source - Docker image name `cgap/cgap:v25`
  * Example Tibanna input jsons for individual steps

For more detailed documentation : https://cgap-pipeline.readthedocs.io/en/latest

### Updating portal objects
The following command patches/posts all portal objects including softwares, file formats and workflows
```
python post_patch_to_portal.py [--ff-env=<env_name>] [--del-prev-version]
                               [--skip-software]
                               [--skip-file-format] [--skip-file-reference]
                               [--skip-workflow] [--skip-metaworkflow]
                               [--ugrp-unrelated] [--ignore-key-conflict]
# env_name : fourfront-cgapwolf (default), fourfront-cgap
```

### Version updates

#### v25
* unrelated for novoCaller are now created from UGRP samples run with the alt index
* ApplyBQSR now runs in parallel

#### v24
* changed bwa mem to use additional index files for alternative contigs

#### v23
* modified dbNSFP plugin for VEP to allow for annotation of non-missense variants
* replaced GNU Parallel with xargs to improve error detection
* turned off mounting to improve error detection

#### v22
* modified VEP to bring PhyloP30, PhyloP100, PhastCons100, and CADD Phred scores from source files instead of from dbNSFP
  * previously, these scores were only available for non-synonymous variants
* modified VEP to annotate gnomAD v2.1.1 exome data for variants
* added a step to expand the number of variants receiving hgvsg and hg19 liftover annotations

#### v21
* added step to correct dbSNP error from GATK

#### v20
* added step to add samplegeno annotation to variants
* conversion of ALT allele `-` back to `*` after VEP annotation is no longer performed.
* updated granite version - vcf.gz is read directly rather than is downloaded and unzipped.
* bamsnap empty zip file bug fix
* bamsnap png file path changed from `chr1:1234.png` to `chr1_1234.png`

#### v19
* added indels realignment when splitting variants with bcftools
* extended ClinVar fields used by VEP
* removed older gnomAD used by VEP by default
* added geneList to filtering
* Bamsnap bug fix reflected in the portal objects

#### v18
* VEP is now the main source for annotations
  * updated VEP to v101
* Bamsnap bug fix for reference fasta sequence being scrambled with multithreading.

#### v17
* added support for novel indels
  * added step to run VEP to annotate novel indels
* updated mutanno version
  * can now handle multiple mti files for annotation
* updated granite version
  * default for VEP is CSQ

#### v16
* mutanno
  * fixed multi-allelic variants split in microannotation
  * fixed PL annotation in microannotation
  * fixed ENSEMBLANNOT annotation in microannotation

#### v15
* comHet
  * impact assignment changed, S/C treated the same as H/M

#### v14
* new workflows
  * comHet
  * filtering (whiteList, cleanVCF and blackList as single step)
  * bamsnap
* solved EOF issue with add-readgroup
* changes in annotation (mutanno version and options)
* changes in filtering criteria

#### v13
* cram2fastq
  * faster fastq compression using pigz
* new workflows
  * microannotation
  * whitelist
  * blacklist
  * novocaller
  * full annotation
  * cram2bam

#### v12
* cram2fastq added
* add-readgroup
  * EOF marker missing error fixed
  * added compatibility to older format for read ID
