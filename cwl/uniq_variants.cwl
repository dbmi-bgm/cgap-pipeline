#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [uniq_variants.sh]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
    doc: expect the path to the vcf gz file

outputs:
  - id: output
    type: File
    outputBinding:
      glob: "uniq_variants.json"

doc: |
  count the number of unique variants in vcf |
  return a json file
