#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v13

baseCommand: [mpileupCounts-parallel.sh]

inputs:
  - id: input_bam
    type: File
    inputBinding:
      position: 1
    secondaryFiles:
      - .bai
    doc: input bam file

  - id: reference
    type: File
    inputBinding:
      position: 2
    secondaryFiles:
      - ^.dict
      - .fai
    doc: expect the path to the fa file

  - id: regions
    type: File
    inputBinding:
      position: 3
    doc: expect the path to the file defining regions

  - id: nthreads
    type: int
    default: 24
    inputBinding:
      position: 6
    doc: number of threads used to run parallel

outputs:
  - id: rck
    type: File
    outputBinding:
      glob: mpileup.out.gz
    secondaryFiles:
      - .tbi

doc: |
  run granite mpileupCounts