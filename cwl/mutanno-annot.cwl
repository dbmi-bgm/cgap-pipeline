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

  - id: mti
    type: File
    inputBinding:
      position: 2
    secondaryFiles:
      - ^.json
    doc: expect the path to the mutanno index files tar archive

  - id: regions
    type: File
    inputBinding:
      position: 3
    doc: expect the path to the file defining regions

  - id: blocksize
    type: int
    inputBinding:
      position: 4

  - id: nthreads
    type: int
    inputBinding:
      position: 5
    doc: number of threads used to run parallel

  - id: add_genoinfo
    type: bool
    default: true
    inputBinding:
      position: 6
      prefix: -add_genoinfo
    doc: add additional sample genotype info
    
  - id: split_multi_allelic_variant
    type: bool
    default: true
    inputBinding:
      position: 7
      prefix: -split_multi_allelic_variant
    doc: split multi allelic variants to multiple lines

outputs:
  - id: output
    type: File
    outputBinding:
      glob: combined.ann.vcf.gz
    secondaryFiles:
      - .tbi

doc: |
  run mutanno annot
