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

  - id: CLINVAR
    type: boolean
    default: null
    doc: flag to whitelist variants with a CLINVAR Id

  - id: CLINVARonly
    type: string[]
    default: null
    doc: only terms and keywords to be saved for CLINVAR

  - id: SpliceAI
    type: float
    default: 0.8
    doc: threshold to whitelist variants by SpliceAI value

  - id: VEP
    type: boolean
    default: true
    doc: use VEP annotations to whitelist exonic and functional relevant variants |
         removed by default intron_variant, intergenic_variant, downstream_gene_variant, |
         upstream_gene_variant, regulatory_region_variant

  - id: VEPrescue
    type: string[]
    default: ["splice_region_variant"]
    doc: terms to overrule removed flags and/or to rescue and whitelist variants

  - id: VEPremove
    type: string[]
    default: null
    doc: additional terms to be removed

  - id: BEDfile
    type: File
    default: null
    doc: expect the path to bed file with positions to whitelist

outputs:
  whiteList_vcf:
    type: File
    outputSource: granite-whiteList/output

  whiteList_vcf-check:
    type: File
    outputSource: integrity-check/output

steps:
  granite-whiteList:
    run: granite-whiteList.cwl
    in:
      input:
        source: input_vcf
      outputfile:
        source: outputfile
      CLINVAR:
        source: CLINVAR
      CLINVARonly:
        source: CLINVARonly
      SpliceAI:
        source: SpliceAI
      VEP:
        source: VEP
      VEPrescue:
        source: VEPrescue
      VEPremove:
        source: VEPremove
      BEDfile:
        source: BEDfile
    out: [output]

  integrity-check:
    run: vcf-integrity-check.cwl
    in:
      input:
        source: granite-whiteList/output
    out: [output]

doc: |
  run granite whiteList |
  run an integrity check on the output vcf
