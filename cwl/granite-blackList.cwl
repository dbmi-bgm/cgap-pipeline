#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [granite, blackList]

inputs:
  - id: input
    type: File
    inputBinding:
      prefix: -i
    doc: expect the path to the vcf file

  - id: outputfile
    type: string
    default: "output.vcf"
    inputBinding:
      prefix: -o
    doc: name of the output file

  - id: bigfile
    type: File
    default: null
    inputBinding:
      prefix: -b
    doc: expect the path to big file with positions set for blacklist

  - id: aftag
    type: string
    default: null
    inputBinding:
      prefix: --aftag
    doc: TAG (TAG=<float>) to be used to filter by population allele frequency

  - id: afthr
    type: float
    default: null
    inputBinding:
      prefix: --afthr
    doc: threshold to filter by population allele frequency

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.outputfile)

doc: |
  run granite blackList
