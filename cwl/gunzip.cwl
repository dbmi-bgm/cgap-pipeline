#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: duplexa/4dn-hic:v43

baseCommand: [gunzip, -c]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.path.split("/").slice(-1)[0].split(".").slice(0,-1).join("."))

stdout: $(inputs.input.path.split("/").slice(-1)[0].split(".").slice(0,-1).join("."))

doc: |
  gunzip a .gz input file into a new output file
