#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v13

baseCommand: [annot-parallel.sh]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
    secondaryFiles:
      - .tbi
    doc: expect the path to the vcf gz file

  - id: resources
    type: File
    inputBinding:
      position: 2
    doc: expect the path to the tar gz archive with resources for annotation

  - id: regions
    type: File
    inputBinding:
      position: 3
    doc: expect the path to the file defining regions

  - id: datasource
    type: File
    inputBinding:
      position: 4
    doc: expect the path to the json file that specify resources to use

  - id: blocksize
    type: int
    inputBinding:
      position: 5

  - id: nthreads
    type: int
    inputBinding:
      position: 6
    doc: number of threads used to run parallel

outputs:
  - id: output
    type: File
    outputBinding:
      glob: combined.ann.vcf.gz
    secondaryFiles:
      - .tbi

doc: |
  run mutanno annot
