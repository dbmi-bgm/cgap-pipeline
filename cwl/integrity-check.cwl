#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [integrity-check.sh]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1

  - id: count
    type: int
    inputBinding:
      position: 2
    doc: 1 count the number of alignments if EOF if present, 0 only check EOF

outputs:
  - id: output
    type: File
    outputBinding:
      glob: integrity_check

doc: |
  run a quick integrity check on the input bam to confirm an EOF exist |
  if successful count the number of alignments
