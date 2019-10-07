#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v10

baseCommand: [vqsr-snv.sh]

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
    default: "out"
    inputBinding:
      position: 3

  - id: hapmap
    type: File
    inputBinding:
      position: 4
    secondaryFiles:
      - .idx
    doc: expect the path to the hapmap vcf file

  - id: omni
    type: File
    inputBinding:
      position: 5
    secondaryFiles:
      - .idx
    doc: expect the path to the omni vcf file

  - id: phase
    type: File
    inputBinding:
      position: 6
    secondaryFiles:
      - .idx
    doc: expect the path to the phase vcf file

  - id: known-sites-snp
    type: File
    inputBinding:
      position: 7
    secondaryFiles:
      - .tbi
    doc: expect the path to the dbsnp vcf gz file

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.prefix + ".mnv.vqsr.vcf.gz")
    secondaryFiles:
      - .tbi
      - ^^^.tranche

doc: |
  run gatk VQSR pipeline |
  evaluate snv
