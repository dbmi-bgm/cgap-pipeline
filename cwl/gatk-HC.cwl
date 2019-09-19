#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v10

baseCommand: [gatk, HaplotypeCaller]

arguments: ["--java-options", "'-Xms8g'", "-O", $(inputs.input_bam.nameroot + ".gvcf"), "--max-alternate-alleles", "3", "--read-filter", "OverclippedReadFilter"]

inputs:
  - id: input_bam
    type: File
    inputBinding:
      position: 1
      prefix: -I
    secondaryFiles:
      - ^.bai

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
    type: String
    default: GVCF
    inputBinding:
      position: 3
      prefix: -ERC
    doc: either 'GVCF' or 'BP_RESOLUTION'

outputs:
  - id: gvcf
    type: File
    outputBinding:
      glob: $(inputs.input_bam.nameroot + ".gvcf")

doc: |
  run gatk HaplotypeCaller
