#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [peddy.sh]

inputs:
  - id: pedigree
    type: string
    inputBinding:
      position: 1
    doc: string representation of pedigree as json

  - id: input_vcf
    type: File
    inputBinding:
      position: 2
    secondaryFiles:
      - .tbi
    doc: expect the path to the vcf file

  - id: family
    type: string
    default: "FAMILY"
    inputBinding:
      position: 3
    doc: family ID to be used for pedigree

  - id: nthreads
    type: int
    default: 4
    inputBinding:
      position: 4
    doc: number of threads to use

outputs:
  - id: qc_json
    type: File
    outputBinding:
      glob: "output.json"

  - id: qc_html
    type: File
    outputBinding:
      glob: "peddy.html"

doc: |
  run peddy
