#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing: [$(inputs.bam)]

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v9

baseCommand: [samtools, index]

inputs:
  - id: bam
    type: File
    inputBinding:
      position: 1
      valueFrom: $(self.basename)

outputs:
  - id: bam_index
    type: File
    outputBinding:
      glob: $(inputs.bam.basename + ".bai")

doc: |
  run samtools index to create a index bai file from input bam file
