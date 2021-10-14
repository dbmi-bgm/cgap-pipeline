#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [python3, /usr/local/bin/liftover_hg19.py]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1
      prefix: -i
    doc: expect the path to the sample vcf gz file

  - id: chainfile
    type: File
    inputBinding:
      position: 2
      prefix: -c
    doc: expect the path to the hg38-to-hg19-chain file

  - id: outputfile
    default: 'liftover.vcf'
    type: string
    inputBinding:
      position: 2
      prefix: -o
    doc: base name of output vcf gz file

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.outputfile + ".gz")
    secondaryFiles:
      - .tbi


doc: |
  run liftover_hg19.py to add hg19_chr and hg19_pos data to INFO field for qualified variants
