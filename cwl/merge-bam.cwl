#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

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

  - id: nthreads
    type: int
    default: 8
    inputBinding:
      position: 4
      prefix: -@
    doc: number of sorting and compression threads

  - id: outbamname
    default: './merged.bam'
    type: string
    inputBinding:
      position: 5
    doc: output file name

  - id: input_bams
    type:
      -
        items: "File"
        type: "array"
    inputBinding:
      position: 6
    doc: input bam files

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.outbamname)

doc: |
  run samtools merge -@ nthreads -c -p out.bam in1.bam in2.bam ...
