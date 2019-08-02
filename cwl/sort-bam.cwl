#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v8

baseCommand: [samtools, sort]

inputs:
  - id: max_memory
    type: string
    inputBinding:
      position: 1
      prefix: -m
    doc: maximum required memory per thread

  - id: num_threads
    type: int
    inputBinding:
      position: 2
      prefix: -@
    doc: number of sorting and compression threads

  - id: input
    type: File
    inputBinding:
      position: 3

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.path.match(/\/([^/]+)\.[^/.]+$/)[1] + "_sorted.bam")

stdout: $(inputs.input.path.match(/\/([^/]+)\.[^/.]+$/)[1] + "_sorted.bam")

doc: |
  run samtools sort to sort input .bam file into _sorted.bam output file
