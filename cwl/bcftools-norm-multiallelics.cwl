#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [bcftools-norm-multiallelics.sh]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
    secondaryFiles:
      - .tbi

  - id: reference
    type: File
    inputBinding:
      position: 2
    secondaryFiles:
      - ^.dict
      - .fai
    doc: expect the path to the fa file

outputs:
  - id: output
    type: File
    outputBinding:
      glob: split.vcf.gz
    secondaryFiles:
      - .tbi

doc: |
  run bcftools norm to split multiallelic variants
