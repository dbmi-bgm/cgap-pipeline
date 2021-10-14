#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [granite, rckTar]

inputs:
  - id: input_rcks
    type:
      type: array
      items: File
      inputBinding:
        prefix: --file
    secondaryFiles:
      - .tbi
    doc: list of rck gz files to be archived

  - id: outputfile
    type: string
    default: "files.rck.tar"
    inputBinding:
      prefix: -t
    doc: name of the output file

outputs:
  - id: rck_tar
    type: File
    outputBinding:
      glob: $(inputs.outputfile)
    secondaryFiles:
      - .index

doc: |
  create tar archive and associate index file from bgzip and tabix indexed rck files
