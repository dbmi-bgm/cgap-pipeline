#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: cgap/cgap:v13

baseCommand: [granite, novoCaller]

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

  - id: unrelated_index
    type: File
    inputBinding:
      prefix: -u
    doc: TSV file containing ID<TAB>Path/to/file for unrelated |
         files used to train the model (rck gz)

  - id: trio_index
    type: File
    inputBinding:
      prefix: -t
    doc: TSV file containing ID<TAB>Path/to/file for family |
         files, the PROBAND must be listed as LAST (rck gz)

  - id: ppthr
    type: float
    default: null
    inputBinding:
      prefix: --ppthr
    doc: threshold to filter by posterior probability for de novo calls

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
  run granite novoCaller with rck files
