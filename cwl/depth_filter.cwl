#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [python3, /usr/local/bin/depth_filter.py]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
      prefix: -i
    doc: expect the path to the sample vcf gz file

  - id: min_depth
    type: int
    inputBinding:
      position: 2
      prefix: -d
    doc: expect the minimum DP (depth) value for a given variant, at least 1 sample must have DP >= min_depth to keep a variant

  - id: outputfile
    default: 'depth_filtered.vcf'
    type: string
    inputBinding:
      position: 3
      prefix: -o
    doc: name of output intermediate vcf file

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.outputfile + ".gz")
    secondaryFiles:
      - .tbi


doc: |
  run depth_filter.py to remove variants that do not have at least 1 sample with DP >= min_depth
