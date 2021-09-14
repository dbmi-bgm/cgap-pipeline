#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [bwa-mem-to-bam_no_unzip.sh]

inputs:
  - id: fastq_R1
    type: File
    inputBinding:
      position: 1
    doc: reads file

  - id: fastq_R2
    type: File
    inputBinding:
      position: 2
    doc: mate-reads file

  - id: reference
    type: File
    inputBinding:
      position: 3
      valueFrom: $(self.path.match(/(.*)\.[^.]+$/)[1])
    secondaryFiles:
      - ^.ann
      - ^.amb
      - ^.pac
      - ^.sa
      - ^.alt
    doc: expect the path to the bwt file

  - id: outdir
    type: string
    inputBinding:
      position: 4
    doc: output directory

  - id: prefix
    type: string
    inputBinding:
      position: 5
    doc: prefix of the output file

  - id: nthreads
    type: int
    inputBinding:
      position: 6
    doc: number of threads to be used

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.prefix + ".bam")

stdout: $(inputs.prefix + ".bam")

doc: |
  run bwa mem allowing to specify the number of threads to be used |
  output is piped into a prefix.bam file
