## CGAP pipeline
* This repo contains CGAP pipeline components
  * CWL
  * Docker source - Docker image name `cgap/cgap:v14`
  * Example Tibanna input jsons for individual steps

For more detailed documentation : https://cgap-pipeline.readthedocs.io/en/latest

### Version updates
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
