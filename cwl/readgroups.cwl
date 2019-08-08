#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v9

baseCommand: [python3, /usr/local/bin/AddReadGroups.py]

inputs:
  - id: input_bam
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
  - id: bam_w_readgroups
    type: File
    outputBinding:
      glob: $(inputs.input_bam.nameroot + "_rg.bam")

doc: |
  run python3 AddReadGroups.py -i input_bam -s sample_name -t nthreads to mark and assign reads from a .bam input file to a new read group into a output _rg.bam file
