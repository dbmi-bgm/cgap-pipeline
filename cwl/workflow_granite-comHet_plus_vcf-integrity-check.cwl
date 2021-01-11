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

  - id: trio
    type: string[]
    default: null
    doc: list of sample IDs for trio, PROBAND_ID [PARENT_ID] [PARENT_ID]

  - id: impact
    type: boolean
    default: true
    doc: flag to add impact to potential compound heterozygous

  - id: sep
    type: string
    default: null
    doc: separator to use for subfields

  - id: VEPtag
    type: string
    default: null
    doc: VEP tag to use

outputs:
  comHet_vcf:
    type: File
    outputSource: sort-bgzip-vcf/output

  comHet_vcf-json:
    type: File
    outputSource: granite-comHet/output_log_json

  comHet_vcf-check:
    type: File
    outputSource: integrity-check/output

steps:
  granite-comHet:
    run: granite-comHet.cwl
    in:
      input:
        source: input_vcf
      outputfile:
        source: outputfile
      trio:
        source: trio
      impact:
        source: impact
      sep:
        source: sep
      VEPtag:
        source: VEPtag
    out: [output, output_log_json]

  sort-bgzip-vcf:
    run: sort-bgzip-vcf.cwl
    in:
      input:
        source: granite-comHet/output
    out: [output]

  integrity-check:
    run: vcf-integrity-check.cwl
    in:
      input:
        source: sort-bgzip-vcf/output
    out: [output]

doc: |
  run granite comHet with impact |
  run an integrity check on the output vcf
