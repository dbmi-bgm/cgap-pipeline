#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: duplexa/picard-2.20.2:v1

# baseCommand: [picard, -Xmx160G, -Xms160G, MarkDuplicates]
baseCommand: [picard, MarkDuplicates]

arguments: ["O=", $(inputs.input.nameroot + ".rm.bam"), "M=", $(inputs.input.nameroot + "_duplicate_metrics.txt"), "TMP_DIR=", "/tmp"]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
      prefix: I=

  - id: max_records_in_ram
    type: int
    inputBinding:
      position: 2
      prefix: MAX_RECORDS_IN_RAM=
    doc: max number of records stored in RAM before spilling to disk

  - id: duplicate_pixel_distance
    type: int
    inputBinding:
      position: 3
      prefix: OPTICAL_DUPLICATE_PIXEL_DISTANCE=
    doc: max offset between two duplicate clusters in order to consider them optical duplicates

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.nameroot + ".rm.bam")

  - id: out_matrix
    type: File
    outputBinding:
      glob: $(inputs.input.nameroot + "_duplicate_metrics.txt")

doc: |
  run picard MarkDuplicates to mark the duplicates in the input .bam file into a new .rm.bam output file |
  generate a _duplicate_metrics.txt file with metrics about duplicates identified
