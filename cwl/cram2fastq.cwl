#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v12-tmp

baseCommand: [cram_to_fastq.sh]

inputs:
  - id: input_cram
    type: string
    inputBinding:
      position: 1
      prefix: -i
    doc: input cram file

  - id: nthreads
    type: int
    inputBinding:
      position: 2
      prefix: -p
    doc: number of compression threads

  - id: input_fasta
    type: File
    inputBinding:
      position: 3
      prefix: -f
    doc: input reference fasta file (optional, if not provided, the reference will be downloaded and combined on the fly)
  
  - id: input_md5_list
    type: File
    inputBinding:
      position: 4
      prefix: -m
    doc: md5 list of the input reference fasta file (optional, if not provided, the reference will be downloaded and combined on the fly)

  - id: out_prefix
    type: File
    inputBinding:
      position: 5
      prefix: -o
    default: "out"
    doc: prefix of the output files (<out_prefix>.1.fastq.gz and <out_prefix>.2.fastq.gz)
      
outputs:
  - id: output_fastq1
    type: File
    outputBinding:
      glob: $(inputs.out_prefix + ".1.fastq.gz")

  - id: output_fastq2
    type: File
    outputBinding:
      glob: $(inputs.out_prefix + ".3.fastq.gz")

doc: |
  run cram_to_fastq.sh -i input_cram -p nthreads -f input_fasta -m input_md5_list -o out_prefix
