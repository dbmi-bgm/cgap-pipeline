#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: duplexa/4dn-hic:v43

baseCommand: [samtools, view, -S, -h, -b]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.path.match(/\/([^/]+)\.[^/.]+$/)[1] + ".bam")

stdout: $(inputs.input.path.match(/\/([^/]+)\.[^/.]+$/)[1] + ".bam")

doc: |
  run samtools view to convert .sam input file into .bam output file
