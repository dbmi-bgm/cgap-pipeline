#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v8

baseCommand: [samtools, merge]

inputs:
  - id: reads_grouped_by_name
    type: boolean
    default: true
    inputBinding:
      position: 1
      prefix: -c
    doc: reads are grouped by readnames

  - id: merge_redundant_headers
    type: boolean
    default: true
    inputBinding:
      position: 2
      prefix: -p
    doc: redundant RG headers are merged

  - id: outbamname
    default: './merged.bam'
    type: string
    inputBinding:
      position: 3
    doc: output file name

  - id: input_bams
    type: 
      - 
        items: "File"
        type: "array"
    inputBinding:
      itemSeparator: " "
      position: 4
      separate: true
    doc: input bam files

outputs:
  - id: merged_bam
    type: File
    outputBinding:
      glob: $(inputs.outbamname)

doc: |
  run samtools merge -c -p out.bam in1.bam in2.bam ...
