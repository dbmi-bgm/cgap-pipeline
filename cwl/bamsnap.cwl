#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v14

baseCommand: [bamsnap]

arguments: ["-margin", "50", "-read_group", "strand", "-plot_margin_left", "20", \
            "-plot_margin_right", "20", "-border", "-save_image_only", "-zipout", \
            "-draw", "coordinates", "bamplot", "base", "gene", \
            "-bamplot", "coverage", "base", "read"]

inputs:
  - id: input_bams
    type:
      type: array
      items: File
      inputBinding:
        prefix: -bam
        position: 1
    secondaryFiles:
      - .bai
    doc: list of bam files to be snapped

  - id: input_vcf
    type: string
    inputBinding:
      position: 2
      prefix: -vcf
    doc: vcf file containing the variants to be snapped

  - id: ref
    type: string
    inputBinding:
      position: 4
      prefix: -ref
    secondaryFiles:
      - ^.dict
      - .fai
    doc: reference genome fasta

  - id: titles
    type:
      type: array
      items: string
      inputBinding:
        position: 5
        prefix: -title
    doc: list of titles (e.g. "NA12877 (Father)")

  - id: outprefix
    type: string
    inputBinding:
      position: 6
      prefix: -out
    default: out
    doc: prefix of the output zip file

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.outprefix + ".zip")

doc: |
  run bamsnap to create snapshot images of the variants in the input vcf
