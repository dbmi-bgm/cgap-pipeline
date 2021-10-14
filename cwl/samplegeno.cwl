#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [samplegeno.sh]

inputs:
  - id: input_vcf
    type: File
    inputBinding:
      position: 1
    doc: expect the path to the vcf file

outputs:
  - id: samplegeno_vcf
    type: File
    outputBinding:
      glob: output.vcf.gz
    secondaryFiles:
      - .tbi

doc: |
  run samplegeno.py
