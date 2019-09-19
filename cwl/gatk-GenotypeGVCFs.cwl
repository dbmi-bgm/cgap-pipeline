#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v10

baseCommand: [gatk, --java-options, \"-Xmx4g\", GenotypeGVCFs]

arguments: ["-O", $(inputs.prefix + ".vcf.gz")]

inputs:
  - id: input_gvcf
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
      - .idx
    doc: expect the path to the dbsnp vcf file

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
