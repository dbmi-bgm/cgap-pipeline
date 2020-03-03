#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v13

baseCommand: [tar-novoCaller.sh]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
    doc: expect the path to the vcf file

  - id: outputfile
    type: string
    default: "output.vcf"
    inputBinding:
      position: 2
    doc: name of the output file

  - id: unrelated
    type: File
    inputBinding:
      position: 3
    secondaryFiles:
      - .index
    doc: expect the rck tar archive with unrelated files used by the model

  - id: trio
    type: File
    inputBinding:
      position: 4
    secondaryFiles:
      - .index
    doc: expect the rck tar archive with trio files used by the model

  - id: ppthr
    type: float
    default: 0
    inputBinding:
      position: 5
    doc: threshold to filter by posterior probability for de novo calls

  - id: aftag
    type: string
    default: ''
    inputBinding:
      position: 6
    doc: TAG (TAG=<float>) to be used to filter by population allele frequency

  - id: afthr
    type: float
    default: 0
    inputBinding:
      position: 7
    doc: threshold to filter by population allele frequency

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.outputfile)

doc: |
  run granite novoCaller with rck files
