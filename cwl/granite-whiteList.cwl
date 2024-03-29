#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [granite, whiteList]

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

  - id: CLINVAR
    type: boolean
    default: null
    inputBinding:
      prefix: --CLINVAR
    doc: flag to whitelist variants with a CLINVAR Id

  - id: CLINVARonly
    type: string[]
    default: null
    inputBinding:
      prefix: --CLINVARonly
    doc: only terms and keywords to be saved for CLINVAR

  - id: SpliceAI
    type: float
    default: null
    inputBinding:
      prefix: --SpliceAI
    doc: threshold to whitelist variants by SpliceAI value

  - id: VEP
    type: boolean
    default: null
    inputBinding:
      prefix: --VEP
    doc: use VEP annotations to whitelist exonic and functional relevant variants |
         removed by default intron_variant, intergenic_variant, downstream_gene_variant, |
         upstream_gene_variant, regulatory_region_variant

  - id: VEPrescue
    type: string[]
    default: null
    inputBinding:
      prefix: --VEPrescue
    doc: terms to overrule removed flags and/or to rescue and whitelist variants

  - id: VEPremove
    type: string[]
    default: null
    inputBinding:
      prefix: --VEPremove
    doc: additional terms to be removed

  - id: BEDfile
    type: File
    default: null
    inputBinding:
      prefix: --BEDfile
    doc: expect the path to bed file with positions to whitelist

  - id: VEPsep
    type: string
    default: null
    inputBinding:
      prefix: --VEPsep
    doc: VEP separator to use for subfields

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

doc: |
  run granite whiteList
