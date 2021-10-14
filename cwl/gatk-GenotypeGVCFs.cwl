#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [GenotypeGVCFs-parallel.sh]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
    secondaryFiles:
      - .tbi
    doc: expect the path to the gvcf gz file

  - id: reference
    type: File
    inputBinding:
      position: 2
    secondaryFiles:
      - .fai
      - ^.dict
    doc: expect the path to the fa file

  - id: known-sites-snp
    type: File
    inputBinding:
      position: 3
    secondaryFiles:
      - .tbi
    doc: expect the path to the dbsnp vcf gz file

  - id: chromosomes
    type: File
    inputBinding:
      position: 4
    doc: expect the path to the file defining chromosomes

  - id: nthreads
    type: int
    inputBinding:
      position: 5
    doc: number of threads used to run parallel

outputs:
  - id: output
    type: File
    outputBinding:
      glob: combined.vcf.gz
    secondaryFiles:
      - .tbi

doc: |
  run gatk GenotypeGVCFs
