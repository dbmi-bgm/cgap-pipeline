#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v10

baseCommand: [gatk, --java-options, \"-Xmx4g\", GenotypeGVCFs, -O, $(inputs.prefix + ".vcf.gz")]

inputs:
  - id: input_gvcf
    type: File
    inputBinding:
      position: 1
      prefix: -V
    secondaryFiles:
      - .tbi
    doc: format input.gvcf.gz

  - id: reference
    type: File
    inputBinding:
      position: 2
      prefix: -R
    secondaryFiles:
      - .fai
      - ^.dict
    doc: format reference.fa

  - id: dbsnp
    type: File
    inputBinding:
      position: 3
      prefix: --dbsnp
    secondaryFiles:
      - .idx
    doc: format dbsnp.vcf

  - id: verbosity
    type: string
    inputBinding:
      position: 4
      prefix: -verbosity
    default: INFO

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.prefix + ".vcf.gz")

doc: |
  run gatk GenotypeGVCFs
