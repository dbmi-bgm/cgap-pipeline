#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [granite, comHet]

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

  - id: trio
    type: string[]
    default: null
    inputBinding:
      prefix: --trio
    doc: list of sample IDs for trio, PROBAND_ID [PARENT_ID] [PARENT_ID]

  - id: impact
    type: boolean
    default: null
    inputBinding:
      prefix: --impact
    doc: flag to add impact to potential compound heterozygous

  - id: sep
    type: string
    default: null
    inputBinding:
      prefix: --sep
    doc: separator to use for subfields

  - id: VEPtag
    type: string
    default: null
    inputBinding:
      prefix: --VEPtag
    doc: VEP tag to use

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.outputfile)

  - id: output_log_json
    type: File
    outputBinding:
      glob: $(inputs.outputfile + ".json")

doc: |
  run granite comHet with impact
