#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [ApplyBQSR-parallel.sh]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
    doc: input file

  - id: reference
    type: File
    inputBinding:
      position: 2
    secondaryFiles:
      - ^.dict
      - .fai
    doc: expect the path to the fa file

  - id: bqsr
    type: File
    inputBinding:
      position: 3
    doc: expect the path to the recalibration_report

  - id: static-quantized-quals_1
    type: int
    inputBinding:
      position: 4
    doc:

  - id: static-quantized-quals_2
    type: int
    inputBinding:
      position: 5
    doc:

  - id: static-quantized-quals_3
    type: int
    inputBinding:
      position: 6
    doc:

  - id: nthreads
    type: int
    default: 28
    inputBinding:
      position: 7
    doc: number of threads used to run parallel

outputs:
  - id: output
    type: File
    outputBinding:
      glob: recalibrated.bam
    secondaryFiles:
        - .bai

doc: |
  run gatk ApplyBQSR
