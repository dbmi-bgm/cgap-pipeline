#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v10-b

baseCommand: [gatk, HaplotypeCaller]

arguments: ["--java-options", '-Xms8g', "-O", $(inputs.input.nameroot + ".gvcf.gz"), "--max-alternate-alleles", "3", "--read-filter", "OverclippedReadFilter"]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
      prefix: -I
    secondaryFiles:
      - .bai

  - id: reference
    type: File
    inputBinding:
      position: 2
      prefix: -R
    secondaryFiles:
      - ^.dict
      - .fai
    doc: expect the path to the fa file

  - id: ERC
    type: string
    default: GVCF
    inputBinding:
      position: 3
      prefix: -ERC
    doc: either 'GVCF' or 'BP_RESOLUTION'

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.nameroot + ".gvcf.gz")
    secondaryFiles:
      - .tbi

doc: |
  run gatk HaplotypeCaller