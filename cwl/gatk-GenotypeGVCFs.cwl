#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v10-b

baseCommand: [gatk, GenotypeGVCFs]

arguments: ["--java-options", '-Xmx4g', "-O", $(inputs.input.prefix + ".vcf.gz")]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
      prefix: -V
    secondaryFiles:
      - .tbi
    doc: expect the path to the gvcf gz file

  - id: reference
    type: File
    inputBinding:
      position: 2
      prefix: -R
    secondaryFiles:
      - .fai
      - ^.dict
    doc: expect the path to the fa file

  - id: known-sites-snp
    type: File
    inputBinding:
      position: 3
      prefix: --dbsnp
    secondaryFiles:
      - .tbi
    doc: expect the path to the dbsnp vcf gz file

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
      glob: $(inputs.input.prefix + ".vcf.gz")

doc: |
  run gatk GenotypeGVCFs
