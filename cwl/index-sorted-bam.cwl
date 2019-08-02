#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing: [$(inputs.input)]

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v8

baseCommand: [samtools, index]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
      valueFrom: $(self.basename)

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.basename + ".bai")

doc: |
  run samtools index to create a index .bai file from input .bam file
