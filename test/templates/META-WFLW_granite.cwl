cwlVersion: v1.2.0-dev1

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  # Files
  - id: input_vcf
    type: File
    doc: expect the path to the vcf file

  - id: genes
    type: File
    doc: expect the path to the tsv file with list of genes to apply

  - id: BEDfile
    type: File
    default: null
    doc: expect the path to bed file with positions to whitelist

  - id: unrelated
    type: File
    secondaryFiles:
      - .index
    doc: expect the rck tar archive with unrelated files used by the model

  - id: trio
    type: File
    secondaryFiles:
      - .index
    doc: expect the rck tar archive with trio files used by the model

  # Parameters
  - id: SpliceAI
    type: float
    default: 0.2
    doc: threshold to whitelist variants by SpliceAI value

  - id: aftag
    type: string
    default: "gnomADg_AF"
    doc: TAG to be used to filter by population allele frequency

  - id: afthr
    type: float
    default: 0.01
    doc: threshold to filter by population allele frequency

  - id: trio_IDs
    type: string[]
    default: null
    doc: list of sample IDs for trio, PROBAND_ID [PARENT_ID] [PARENT_ID]

  - id: pedigree
    type: string
    doc: string representation of pedigree as json

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
  # out_filtering:
  #   type: File
  #   outputSource: filtering/merged_vcf
  #
  # out_filtering-check:
  #   type: File
  #   outputSource: filtering/merged_vcf-check

  out_comHet:
    type: File
    outputSource: comHet/comHet_vcf

  out_comHet-check:
    type: File
    outputSource: comHet/comHet_vcf-check

  out_comHet-json:
    type: File
    outputSource: comHet/comHet_vcf-json

  out_qc-json:
    type: File
    outputSource: qcVCF/qc_json

  out_uniq-variants:
    type: File
    outputSource: qcVCF/uniq_variants

steps:
  filtering:
    run: workflow_granite-filtering_plus_vcf-integrity-check.cwl
    in:
      input_vcf:
        source: input_vcf
      genes:
        source: genes
      BEDfile:
        source: BEDfile
      SpliceAI:
        source: SpliceAI
      aftag:
        source: aftag
      afthr:
        source: afthr
    out: [merged_vcf, merged_vcf-check]

  novoCaller:
    run: workflow_granite-novoCaller-rck_plus_vcf-integrity-check.cwl
    in:
      val: # that is for evaluating when condition
        source: trio_IDs
      input_vcf:
        source: filtering/merged_vcf
      unrelated:
        source: unrelated
      trio:
        source: trio
    when: $(inputs.val.length > 2)
    out: [novoCaller_vcf, novoCaller_vcf-check]

  comHet:
    run: workflow_granite-comHet_plus_vcf-integrity-check.cwl
    in:
      input_vcf:
        source:
          - novoCaller/novoCaller_vcf
          - filtering/merged_vcf
        pickValue: first_non_null
      trio:
        source: trio_IDs
    out: [comHet_vcf, comHet_vcf-check, comHet_vcf-json]

  qcVCF:
    run: workflow_granite-qcVCF_plus_uniq_variants.cwl
    in:
      input_vcf:
        source: comHet/comHet_vcf
      pedigree:
        source: pedigree
      samples:
        source: trio_IDs
      trio_errors:
        source: trio_errors
      het_hom:
        source: het_hom
      ti_tv:
        source: ti_tv
    out: [qc_json, uniq_variants]

doc: |
