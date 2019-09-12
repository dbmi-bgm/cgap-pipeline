#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/bamqc:v2

baseCommand: [bamqc.sh]

inputs:
  - id: input_bam
    type: File
    inputBinding:
      position: 1
    secondaryFiles:
      - .bai

  - id: xmx
    type: string
    default: 5G
    inputBinding:
      position: 2

  - id: xms
    type: string
    default: 5G
    inputBinding:
      position: 3

outputs:
  - id: report_zip
    type: File
    outputBinding:
      glob: qcboard_bam.zip

doc: |
  create quality control report for a bam file
