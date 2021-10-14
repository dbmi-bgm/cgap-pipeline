#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [python, /usr/local/bin/bamqc.py]

inputs:
  - id: input_bam
    type: File
    inputBinding:
      position: 1
    doc: expect the path to the bam file

  - id: sample
    type: string
    inputBinding:
      prefix: -s
    doc: sample name to go into the output json file

  - id: nthreads
    type: int
    default: 16
    inputBinding:
      prefix: -p
    doc: number of processes to use

  - id: eff_genome_size
    type: long
    default: 2913022398
    inputBinding:
      prefix: --eff-genome-size
    doc: effective genome size (number of non-N bases) (default is for GRCh38)

  - id: skip_collate
    type: boolean
    default: false
    inputBinding:
      prefix: --skip-collate
    doc: skip collate (input bam file is collated by read IDs)

outputs:
  - id: qc_json
    type: File
    outputBinding:
      glob: "*.stats"

doc: |
  run bamqc
