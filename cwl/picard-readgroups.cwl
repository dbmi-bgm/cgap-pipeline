#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v7

baseCommand: [picard, AddOrReplaceReadGroups]

arguments: ["O=", $(inputs.input.nameroot + "_rg.bam")]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
      prefix: I=

  - id: rgid
    type: int
    inputBinding:
      position: 2
      prefix: RGID=
    doc: read group ID

  - id: rglb
    type: string
    inputBinding:
      position: 3
      prefix: RGLB=
    doc: read group library

  - id: rgpl
    type: string
    inputBinding:
      position: 4
      prefix: RGPL=
    doc: read group platform

  - id: rgpu
    type: string
    inputBinding:
      position: 5
      prefix: RGPU=
    doc: read group platform unit

  - id: rgsm
    type: int
    inputBinding:
      position: 6
      prefix: RGSM=
    doc: read group sample name

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.nameroot + "_rg.bam")

doc: |
  run picard AddOrReplaceReadGroups to mark and assign reads from a .bam input file to a new read group into a output _rg.bam file
