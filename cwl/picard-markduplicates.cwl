#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v9

baseCommand: [picard, MarkDuplicates]

arguments: ["O=", $(inputs.input.nameroot + "_rm.bam"), "M=", "duplicate_metrics.txt", "TMP_DIR=", "/tmp", "ASSUME_SORT_ORDER=", "queryname"]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
      prefix: I=

  - id: xmx
    type: string
    inputBinding:
      position: 2

  - id: xms
    type: string
    inputBinding:
      position: 3

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
  run picard MarkDuplicates to mark the duplicates in the input .bam file into a new _rm.bam output file |
  generate a duplicate_metrics.txt file with metrics about duplicates identified
