#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [granite, qcVCF]

inputs:
  - id: input_vcf
    type: File
    inputBinding:
      prefix: -i
    doc: expect the path to the vcf gz file

  - id: outputfile
    type: string
    default: "output.json"
    inputBinding:
      prefix: -o
    doc: name of the output file

  - id: pedigree
    type: string
    inputBinding:
      prefix: -p
    doc: string representation of pedigree as json

  - id: samples
    type: string[]
    inputBinding:
      prefix: --samples
    doc: samples to collect metrics for

  - id: trio_errors
    type: boolean
    default: null
    inputBinding:
      prefix: --trio_errors
    doc: add statistics on mendelian errors based on trio

  - id: het_hom
    type: boolean
    default: null
    inputBinding:
      prefix: --het_hom
    doc: add heterozygosity ratio and statistics on zygosity

  - id: ti_tv
    type: boolean
    default: null
    inputBinding:
      prefix: --ti_tv
    doc: add transition-transversion ratio and statistics on substitutions

outputs:
  - id: qc_json
    type: File
    outputBinding:
      glob: $(inputs.outputfile)

doc: |
  run granite qcVCF
