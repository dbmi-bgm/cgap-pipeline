#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [CombineGVCFs-parallel.sh]

inputs:
  - id: input_gvcfs
    type:
      -
        items: File
        type: array
    inputBinding:
      position: 4
    secondaryFiles:
      - .tbi
    doc: input gvcf files

  - id: reference
    type: File
    inputBinding:
      position: 1
    secondaryFiles:
      - ^.dict
      - .fai
    doc: expect the path to the fa file

  - id: chromosomes
    type: File
    inputBinding:
      position: 2
    doc: expect the path to the file defining chromosomes

  - id: nthreads
    type: int
    default: 10
    inputBinding:
      position: 3
    doc: number of threads used to run parallel

outputs:
  - id: combined_gvcf
    type: File
    outputBinding:
      glob: combined.gvcf.gz
    secondaryFiles:
      - .tbi

doc: |
  run gatk CombineGVCFs
