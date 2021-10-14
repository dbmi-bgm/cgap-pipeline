#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [parallel_dbSNP_ID_fixer.sh]

inputs:
  - id: dbSNP_ref_vcf
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
    doc: expect the path to the sample vcf gz file

  - id: region_file
    type: File
    inputBinding:
      position: 3
    doc: expect the path to the hg38 region file

  - id: nthreads
    type: int
    default: 2
    inputBinding:
      position: 4
    doc: number of threads used to run parallel

outputs:
  - id: output
    type: File
    outputBinding:
      glob: 'fixed*vcf.gz'
    secondaryFiles:
      - .tbi

doc: |
  run dbSNP_ID_fixer.py to update sample vcf ID column with rsID(s)
