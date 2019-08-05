#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v8

baseCommand: [gatk, BaseRecalibrator]

arguments: ["-O", $(inputs.input.nameroot + "_recalibration_report"), "--use-original-qualities"]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
      prefix: -I
    doc: input file .bam

  - id: reference
    type: File
    inputBinding:
      position: 2
      prefix: -R
    secondaryFiles:
      - ^.dict
      - .fai
    doc: expect the path to the .fa file

  - id: known-sites-snp
    type: File
    inputBinding:
      position: 3
      prefix: --known-sites
    secondaryFiles:
      - .tbi
    doc: expect the path to the dbsnp .vcf.gz file

  - id: known-sites-indels
    type: File
    inputBinding:
      position: 4
      prefix: --known-sites
    secondaryFiles:
      - .idx
    doc: expect the path to the indel .vcf file

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.nameroot + "_recalibration_report")

doc: |
  run gatk BaseRecalibrator
