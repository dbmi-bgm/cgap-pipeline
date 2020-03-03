#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v13

baseCommand: [tar-rck.py]

inputs:
  - id: input
    type: string[]
    inputBinding:
      prefix: --files
    doc: list of files to be archived

outputs:
  - id: output
    type: File
    outputBinding:
      glob: files.rck.tar
    secondaryFiles:
      - .index

doc: |
  create tar archive and associate index file to be used |
  by novoCaller from bgzip and tabix indexed rck files
