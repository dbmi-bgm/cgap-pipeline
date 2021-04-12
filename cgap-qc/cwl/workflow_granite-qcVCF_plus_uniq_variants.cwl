cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: input_vcf
    type: File
    doc: expect the path to the vcf gz file

  - id: pedigree
    type: string
    doc: string representation of pedigree as json

  - id: samples
    type: string[]
    doc: samples to collect metrics for

  - id: trio_errors
    type: boolean
    doc: add statistics on mendelian errors based on trio

  - id: het_hom
    type: boolean
    doc: add heterozygosity ratio and statistics on zygosity

  - id: ti_tv
    type: boolean
    doc: add transition-transversion ratio and statistics on substitutions

outputs:
  qc_json:
    type: File
    outputSource: granite-qcVCF/qc_json

  uniq_variants:
    type: File
    outputSource: count_variants/output

steps:
  granite-qcVCF:
    run: granite-qcVCF.cwl
    in:
      input_vcf:
        source: input_vcf
      pedigree:
        source: pedigree
      samples:
        source: samples
      trio_errors:
        source: trio_errors
      het_hom:
        source: het_hom
      ti_tv:
        source: ti_tv
    out: [qc_json]

  count_variants:
    run: uniq_variants.cwl
    in:
      input:
        source: input_vcf
    out: [output]

doc: |
  run granite qcVCF |
  count the number of unique variants in vcf
