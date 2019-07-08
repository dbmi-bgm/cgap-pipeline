#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing: [$(inputs.input)]

hints:
  - class: DockerRequirement
    dockerPull: duplexa/samtools-1.9:v1

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
    secondaryFiles:
      - .bai
    outputBinding:
      glob: $(inputs.input.basename)

doc: |
  run samtools index to create a index .bai file from input .bam file
