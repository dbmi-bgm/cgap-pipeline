#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v9

baseCommand: [gatk, ApplyBQSR]

arguments: ["-O", $(inputs.input.nameroot + "_recalibrated_full.bam"), "--use-original-qualities"]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
      prefix: -I
    doc: input file

  - id: reference
    type: File
    inputBinding:
      position: 2
      prefix: -R
    secondaryFiles:
      - ^.dict
      - .fai
    doc: expect the path to the fa file

  - id: bqsr
    type: File
    inputBinding:
      position: 3
      prefix: --bqsr
    doc: expect the path to the recalibration_report

  - id: static-quantized-quals_1
    type: int
    inputBinding:
      position: 4
      prefix: --static-quantized-quals
    doc:

  - id: static-quantized-quals_2
    type: int
    inputBinding:
      position: 5
      prefix: --static-quantized-quals
    doc:

  - id: static-quantized-quals_3
    type: int
    inputBinding:
      position: 6
      prefix: --static-quantized-quals
    doc:

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.nameroot + "_recalibrated_full.bam")
    secondaryFiles: 
        - ".bai"

doc: |
  run gatk ApplyBQSR
