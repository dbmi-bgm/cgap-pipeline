#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [HaplotypeCaller.sh]

inputs:
  - id: input_bam
    type: File
    inputBinding:
      position: 1
    secondaryFiles:
      - .bai
    doc: input bam file

  - id: reference
    type: File
    inputBinding:
      position: 2
    secondaryFiles:
      - ^.dict
      - .fai
    doc: expect the path to the fa file

  - id: regions
    type: File
    inputBinding:
      position: 3
    doc: expect the path to the file defining regions

  - id: threshold
    type: int
    default: 0
    inputBinding:
      position: 4
    doc: -stand-call-conf threshold

  - id: ERC
    type: string
    default: "GVCF"
    inputBinding:
      position: 5
    doc: either "GVCF" or "BP_RESOLUTION"

  - id: nthreads
    type: int
    default: 1
    inputBinding:
      position: 6
    doc: number of threads used to run

outputs:
  - id: gvcf
    type: File
    outputBinding:
      glob: combined.gvcf.gz
    secondaryFiles:
      - .tbi

doc: |
  run gatk HaplotypeCaller
