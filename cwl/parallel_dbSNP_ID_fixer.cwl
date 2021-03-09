#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v21

baseCommand: [parallel_dbSNP_ID_fixer.sh]

inputs:
  - id: reference
    type: File
    inputBinding:
      position: 1
    secondaryFiles:
      - .tbi
    doc: expect the path to the reference dbSNP vcf gz file

  - id: input
    type: File
    inputBinding:
      position: 2
    secondaryFiles:
      - .tbi
    doc: expect the path to the sample gvcf gz file

  - id: region_file
    type: File
    inputBinding:
      position: 3
    doc: expect the path to the hg38 region file

  - id: nthreads
    type: int
    inputBinding:
      position: 4
    doc: number of threads used to run parallel

doc: |
  run dbSNP_ID_fixer.py to update sample vcf ID column with rsID(s)
