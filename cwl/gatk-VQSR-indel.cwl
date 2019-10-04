#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v10

baseCommand: [vqsr-indel.sh]

inputs:
  - id: input
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

  - id: prefix
    type: string
    default: "indels"
    inputBinding:
      position: 3

  - id: known-sites-indels
    type: File
    inputBinding:
      position: 4
    secondaryFiles:
      - .idx
    doc: expect the path to the indel vcf file

  - id: max_gaussians
    type: int
    default: 8
    inputBinding:
      position: 5

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.prefix + ".indelmixed.vqsr.vcf.gz")
    secondaryFiles:
      - .tbi

doc: |
  run gatk VQSR pipeline |
  evaluate indels
