cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: input_vcf
    type: File
    doc: expect the path to the vcf file

  - id: outputfile
    type: string
    default: "output.vcf"
    doc: name of the output file

  - id: bigfile
    type: File
    default: null
    doc: expect the path to big file with positions set for blacklist

  - id: aftag
    type: string
    default: null
    doc: TAG (TAG=<float>) to be used to filter by population allele frequency

  - id: afthr
    type: float
    default: null
    doc: threshold to filter by population allele frequency

outputs:
  blackList_vcf:
    type: File
    outputSource: granite-blackList/output

  blackList_vcf-check:
    type: File
    outputSource: integrity-check/output

steps:
  granite-blackList:
    run: granite-blackList.cwl
    in:
      input:
        source: input_vcf
      outputfile:
        source: outputfile
      bigfile:
        source: bigfile
      aftag:
        source: aftag
      afthr:
        source: afthr
    out: [output]

  integrity-check:
    run: vcf-integrity-check.cwl
    in:
      input:
        source: granite-blackList/output
    out: [output]

doc: |
  run granite blackList |
  run an integrity check on the output vcf
