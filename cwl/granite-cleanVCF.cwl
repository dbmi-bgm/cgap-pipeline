#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/snv:VERSION

baseCommand: [granite, cleanVCF]

inputs:
  - id: input_vcf
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

  - id: SpliceAI
    type: float
    default: null
    inputBinding:
      prefix: --SpliceAI
    doc: threshold to rescue intron annotations for variants by SpliceAI value

  - id: VEP
    type: boolean
    default: null
    inputBinding:
      prefix: --VEP
    doc: clean VEP annotations |
         by default are removed intron_variant, intergenic_variant, |
         downstream_gene_variant, upstream_gene_variant, regulatory_region_variant

  - id: VEPrescue
    type: string[]
    default: null
    inputBinding:
      prefix: --VEPrescue
    doc: terms to overrule removed flags to rescue annotations

  - id: VEPremove
    type: string[]
    default: null
    inputBinding:
      prefix: --VEPremove
    doc: additional terms to be removed from annotations

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

  - id: filter_VEP
    type: boolean
    default: null
    inputBinding:
      prefix: --filter_VEP
    doc: filter out variants that are missing VEP after cleaning

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.outputfile)

doc: |
  run granite cleanVCF
