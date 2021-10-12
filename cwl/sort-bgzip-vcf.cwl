#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [sort-bgzip-vcf.sh]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
    doc: expect the path to the vcf file

outputs:
  - id: output
    type: File
    outputBinding:
      glob: sorted.vcf.gz
    secondaryFiles:
      - .tbi

doc: |
  sort, compress and index input vcf file
