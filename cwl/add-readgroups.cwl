#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [python3, /usr/local/bin/cgap-scripts/AddReadGroups.py]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
      prefix: -i

  - id: sample_name
    type: string
    inputBinding:
      position: 2
      prefix: -s
    doc: sample name

  - id: nthreads
    type: int
    inputBinding:
      position: 3
      prefix: -t
    doc: number of threads

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.nameroot + "_rg.bam")

doc: |
  run AddReadGroups.py to mark and assign reads from a bam input file to new read groups
