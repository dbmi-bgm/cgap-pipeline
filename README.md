## CGAP pipeline
* This repo contains CGAP pipeline components
  * CWL
  * Docker source - Docker image name `cgap/cgap:v20`
  * Example Tibanna input jsons for individual steps

For more detailed documentation : https://cgap-pipeline.readthedocs.io/en/latest

### Updating portal objects
The following command patches/posts all portal objects including softwares, file formats and workflows
```
python post_patch_to_portal.py [--ff-env=<env_name>] [--skip-software] [--skip-file-format] [--skip-workflow]
# env_name : fourfront-cgapwolf (default), fourfront-cgap
```

### Version updates
#### v20
* added step to add samplegeno annotation to variants
* updated granite version

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
