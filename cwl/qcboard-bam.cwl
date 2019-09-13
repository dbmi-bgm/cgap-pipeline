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
  - id: report_json
    type: File
    outputBinding:
      glob: qcboard_bam.json

  - id: report_html
    type: File
    outputBinding:
      glob: qcboard_bam.html

doc: |
  create quality control reports for a bam file
