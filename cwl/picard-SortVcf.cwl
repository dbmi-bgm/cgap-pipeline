#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [picard, SortVcf]

arguments: ["O=merged.vcf.gz"]

inputs:
  - id: xmx
    type: string
    default: 4G
    inputBinding:
      position: 1
      separate: false
      prefix: -Xmx

  - id: input_indel
    type: File
    inputBinding:
      position: 2
      separate: false
      prefix: I=
    secondaryFiles:
      - .tbi
    doc: expect the path to the vcf gz indel file

  - id: input_snv
    type: File
    inputBinding:
      position: 3
      separate: false
      prefix: I=
    secondaryFiles:
      - .tbi
    doc: expect the path to the vcf gz snv file

outputs:
  - id: output
    type: File
    outputBinding:
      glob: merged.vcf.gz
    secondaryFiles:
      - .tbi

doc: |
  run picard SortVcf to merge indel and snv vcf gz files
