#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v18

baseCommand: [vep-parallel.sh]

inputs:
  - id: input_vcf
    type: File
    inputBinding:
      position: 1
    secondaryFiles:
      - .tbi
    doc: expect the path to the vcf gz file

  - id: reference
    type: File
    inputBinding:
      position: 2
    secondaryFiles:
      - ^.dict
      - .fai
    doc: expect the path to the fa file

  - id: vep_tar
    type: File
    inputBinding:
      position: 3
    secondaryFiles:
      - ^^^.plugins.tar.gz
    doc: expect the path to the vep tar archive

  - id: regions
    type: File
    inputBinding:
      position: 4
    doc: expect the path to the file defining regions

  - id: mti
    type: File
    inputBinding:
      position: 5
    secondaryFiles:
      - .tbi
      - ^.json
    doc: expect the path to the mutanno index file for micro-annotation

  - id: nthreads
    type: int
    default: 15
    inputBinding:
      position: 6
    doc: number of threads used to run parallel

  - id: version
    type: string
    default: "99"
    inputBinding:
      position: 7
    doc: vep datasource version

  - id: assembly
    type: string
    default: "GRCh38"
    inputBinding:
      position: 8
    doc: genome assembly version

outputs:
  - id: microannot_mti
    type: File
    outputBinding:
      glob: output.microannot.mti.gz
    secondaryFiles:
      - .tbi

  - id: annot_mti
    type: File
    outputBinding:
      glob: output.fullannot.mti.gz
    secondaryFiles:
      - .tbi

doc: |
  run vep on indels |
  produce mti files for full and micro-annotation
