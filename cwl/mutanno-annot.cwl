#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v17

baseCommand: [annot-parallel-mti.sh]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
    secondaryFiles:
      - .tbi
    doc: expect the path to the vcf gz file

  - id: mti
    type: File
    inputBinding:
      position: 2
    secondaryFiles:
      - .tbi
      - ^.json
    doc: expect the path to the mutanno index file

  - id: mti_vep
    type: File
    inputBinding:
      position: 3
    secondaryFiles:
      - .tbi
    doc: expect the path to the mutanno index file for VEP

  - id: regions
    type: File
    inputBinding:
      position: 4
    doc: expect the path to the file defining regions

  - id: nthreads
    type: int
    inputBinding:
      position: 5
    doc: number of threads used to run parallel

  - id: micro_annotation
    type: string
    inputBinding:
      position: 6
    doc: whether this is micro-annotation (1) or full annotation (0)

  - id: chainfile
    type: File
    default: null
    inputBinding:
      position: 7
    doc: expect the path to the chain file for hg19

outputs:
  - id: output
    type: File
    outputBinding:
      glob: combined.ann.vcf.gz
    secondaryFiles:
      - .tbi

doc: |
  run mutanno annot
