#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [merge-sort-vcf.sh]

inputs:
  - id: input_vcf_1
    type: File
    inputBinding:
      position: 1
    doc: input vcf file, 1

  - id: input_vcf_2
    type: File
    inputBinding:
      position: 2
    doc: input vcf file, 2

outputs:
  - id: output
    type: File
    outputBinding:
      glob: sorted.vcf.gz
    secondaryFiles:
      - .tbi

doc: |
  run merge-sort-vcf.sh to merge and sort two vcf files |
  remove duplicate lines
