#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: duplexa/4dn-hic:v43

baseCommand: [bwa, mem]

inputs:
  - id: threads
    type: int
    inputBinding:
      position: 1
      prefix: -t
    doc: number of threads to be used

  - id: reference
    type: File
    inputBinding:
      position: 2
      valueFrom: $(self.path.match(/(.*)\.[^.]+$/)[1])
    secondaryFiles:
      - ^.ann
      - ^.amb
      - ^.pac
      - ^.sa
    doc: expect the path to the .bwt file

  - id: reads
    type:
      type: array
      items: File
    inputBinding:
      position: 3
    doc: reads file and mate-reads file as an array

outputs:
  - id: output
    type: stdout

stdout: $(inputs.reads[0].path.match(/\/([^/]+)\.[^/.]+$/)[1] + ".sam")

doc: |
  run bwa mem allowing to specify the number of threads to be used |
  buffer results to stdout
