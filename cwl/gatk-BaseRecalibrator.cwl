#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [gatk, BaseRecalibrator]

arguments: ["-O", $(inputs.input_bam.nameroot + "_recalibration_report"), "--use-original-qualities"]

inputs:
  - id: input_bam
    type: File
    inputBinding:
      position: 1
      prefix: -I

  - id: reference
    type: File
    inputBinding:
      position: 2
      prefix: -R
    secondaryFiles:
      - ^.dict
      - .fai
    doc: expect the path to the fa file

  - id: known-sites-snp
    type: File
    inputBinding:
      position: 3
      prefix: --known-sites
    secondaryFiles:
      - .tbi
    doc: expect the path to the dbsnp vcf gz file

  - id: known-sites-indels
    type: File
    inputBinding:
      position: 4
      prefix: --known-sites
    secondaryFiles:
      - .idx
    doc: expect the path to the indel vcf file

outputs:
  - id: recalibration_report
    type: File
    outputBinding:
      glob: $(inputs.input_bam.nameroot + "_recalibration_report")

doc: |
  run gatk BaseRecalibrator
