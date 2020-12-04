#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v18

baseCommand: [bcftools-norm-multiallelics.sh]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
    secondaryFiles:
      - .tbi

outputs:
  - id: output
    type: File
    outputBinding:
      glob: split.vcf.gz
    secondaryFiles:
      - .tbi

doc: |
  run bcftools norm to split multiallelic variants
