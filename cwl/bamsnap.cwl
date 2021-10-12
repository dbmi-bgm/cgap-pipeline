#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [bamsnap]

arguments: ["-margin", "50", "-read_group", "strand", "-plot_margin_left", "20",
            "-plot_margin_right", "20", "-border", "-save_image_only", "-zipout",
            "-draw", "coordinates", "bamplot", "base", "gene",
            "-bamplot", "coverage", "base", "read"]

inputs:
  - id: input_bams
    type: File[]
    inputBinding:
      prefix: -bam
      position: 1
    secondaryFiles:
      - .bai
    doc: list of bam files to be snapped

  - id: input_vcf
    type: File
    inputBinding:
      position: 2
      prefix: -vcf
    doc: vcf file containing the variants to be snapped

  - id: ref
    type: File
    inputBinding:
      position: 3
      prefix: -ref
    secondaryFiles:
      - ^.dict
      - .fai
    doc: reference genome fasta

  - id: titles
    type: string[]
    inputBinding:
      position: 4
      prefix: -title
    doc: list of titles (e.g. "NA12877 (Father)")

  - id: nproc
    type: int
    inputBinding:
      position: 5
      prefix: -process
    default: 16
    doc: number of processes to use

  - id: outprefix
    type: string
    inputBinding:
      position: 6
      prefix: -out
    default: bamsnap
    doc: prefix of the output zip file

  - id: exclude_chr
    type: string[]
    inputBinding:
      position: 7
      prefix: -exclude_chr
    default: ["chrM"]
    doc: list of chromosomes to exclude

outputs:
  - id: bamsnap_images
    type: File
    outputBinding:
      glob: $(inputs.outprefix + ".zip")

doc: |
  run bamsnap to create snapshot images of the variants in the input vcf
