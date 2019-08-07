#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:exp

baseCommand: [picard-readgroups.sh]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1

  - id: rgid
    type: int
    inputBinding:
      position: 2
    doc: read group ID

  - id: rglb
    type: string
    inputBinding:
      position: 3
    doc: read group library

  - id: rgpl
    type: string
    inputBinding:
      position: 4
    doc: read group platform

  - id: rgpu
    type: string
    inputBinding:
      position: 5
    doc: read group platform unit

  - id: rgsm
    type: int
    inputBinding:
      position: 6
    doc: read group sample name

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.nameroot + "_rg.bam")

doc: |
  run picard AddOrReplaceReadGroups to mark and assign reads from a .bam input file to a new read group into a output _rg.bam file
