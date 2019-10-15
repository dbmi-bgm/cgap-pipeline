#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v10

baseCommand: [gatk, CombineGVCFs]

arguments: ["-O", "family.gvcf.gz"]

inputs:
  - id: input_gvcfs
    type:
      -
        items: "File"
        type: "array"
    inputBinding:
      position: 1
      prefix: -V
    doc: input gvcf files

  - id: reference
    type: File
    inputBinding:
      position: 2
      prefix: -R
    secondaryFiles:
      - ^.dict
      - .fai
    doc: expect the path to the fa file

outputs:
  - id: family_gvcf
    type: File
    outputBinding:
      glob: family.gvcf.gz
    secondaryFiles:
      - .tbi

doc: |
  run gatk CombineGVCFs
