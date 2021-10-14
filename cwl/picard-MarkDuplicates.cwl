#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [picard, MarkDuplicates]

arguments: ["O=", $(inputs.input.nameroot + "_rm.bam")]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 3
      prefix: I=

  - id: xmx
    type: string
    inputBinding:
      separate: false
      prefix: -Xmx

  - id: xms
    type: string
    inputBinding:
      separate: false
      prefix: -Xms

  - id: metrics_file_name
    type: string
    default: duplicate_metrics.txt
    inputBinding:
      position: 7
      prefix: M=

  - id: tmpdir
    type: string
    default: /tmp
    inputBinding:
      position: 8
      prefix: TMP_DIR=

  - id: sort_order
    type: string
    default: queryname
    inputBinding:
      position: 9
      prefix: ASSUME_SORT_ORDER=

  - id: max_records_in_ram
    type: int
    inputBinding:
      position: 4
      prefix: MAX_RECORDS_IN_RAM=
    doc: max number of records stored in RAM before spilling to disk

  - id: duplicate_pixel_distance
    type: int
    inputBinding:
      position: 5
      prefix: OPTICAL_DUPLICATE_PIXEL_DISTANCE=
    doc: max offset between two duplicate clusters in order to consider them optical duplicates

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.nameroot + "_rm.bam")

  - id: out_metrics
    type: File
    outputBinding:
      glob: duplicate_metrics.txt

doc: |
  run picard MarkDuplicates to mark the duplicates in the input bam file |
  generate a duplicate_metrics.txt file with metrics about duplicates identified
