#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [cram_to_fastq.sh]

inputs:
  - id: cram
    type: File
    inputBinding:
      position: 1
      prefix: -i
    doc: input cram file

  - id: nthreads
    type: int
    inputBinding:
      position: 2
      prefix: -p
    default: 16
    doc: number of compression threads

  - id: reference_fasta
    type:
      - File
      - "null"
    inputBinding:
      position: 3
      prefix: -f
    doc: input reference fasta file (optional, if not provided, the reference will be downloaded and combined on the fly)

  - id: reference_md5_list
    type:
      - File
      - "null"
    inputBinding:
      position: 4
      prefix: -m
    doc: md5 list of the input reference fasta file (optional, if not provided, the reference will be downloaded and combined on the fly)

  - id: out_prefix
    type: string
    inputBinding:
      position: 5
      prefix: -o
    default: "out"
    doc: prefix of the output files (<out_prefix>.1.fastq.gz and <out_prefix>.2.fastq.gz)

outputs:
  - id: fastq1
    type: File
    outputBinding:
      glob: $(inputs.out_prefix + ".1.fastq.gz")

  - id: fastq2
    type: File
    outputBinding:
      glob: $(inputs.out_prefix + ".2.fastq.gz")

doc: |
  run cram_to_fastq.sh -i cram -p nthreads -f reference_fasta -m reference_md5_list -o out_prefix
