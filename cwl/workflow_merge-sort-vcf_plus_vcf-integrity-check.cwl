cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: input_vcf_1
    type: File
    doc: input vcf file, 1

  - id: input_vcf_2
    type: File
    doc: input vcf file, 2

outputs:
  merged_vcf:
    type: File
    outputSource: merge-sort-vcf/output

  merged_vcf-check:
    type: File
    outputSource: integrity-check/output

steps:
  merge-sort-vcf:
    run: merge-sort-vcf.cwl
    in:
      input_vcf_1:
        source: input_vcf_1
      input_vcf_2:
        source: input_vcf_2
    out: [output]

  integrity-check:
    run: vcf-integrity-check.cwl
    in:
      input:
        source: merge-sort-vcf/output
    out: [output]

doc: |
  run merge-sort-vcf.sh to merge and sort two vcf files |
  run an integrity check on the output vcf
