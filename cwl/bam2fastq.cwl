#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [bam_to_fastq.sh]

inputs:
  - id: bam
    type: File
    inputBinding:
      position: 1
      prefix: -i
    doc: input bam file

  - id: nthreads
    type: int
    inputBinding:
      position: 2
      prefix: -p
    default: 16
    doc: number of compression threads

  - id: out_prefix
    type: string
    inputBinding:
      position: 3
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
  run bam_to_fastq.sh -i bam -p nthreads -o out_prefix
