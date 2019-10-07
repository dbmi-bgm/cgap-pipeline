cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: input_vcf
    type: File
    secondaryFiles:
      - .tbi
    doc: expect the path to the vcf gz file

  - id: reference
    type: File
    secondaryFiles:
      - ^.dict
      - .fai
    doc: expect the path to the fa file

  - id: prefix
    type: string
    default: "out"

  - id: known-sites-indels
    type: File
    secondaryFiles:
      - .idx
    doc: expect the path to the indel vcf file

  - id: max_gaussians
    type: int
    default: 8

  - id: hapmap
    type: File
    secondaryFiles:
      - .idx
    doc: expect the path to the hapmap vcf file

  - id: omni
    type: File
    secondaryFiles:
      - .idx
    doc: expect the path to the omni vcf file

  - id: phase
    type: File
    secondaryFiles:
      - .idx
    doc: expect the path to the phase vcf file

  - id: known-sites-snp
    type: File
    secondaryFiles:
      - .tbi
    doc: expect the path to the dbsnp vcf gz file

  - id: xmx
    type: string
    default: 4G

outputs:
  vqsr_vcf:
    type: File
    outputSource: picard-SortVcf/output

  vqsr_vcf-check:
    type: File
    outputSource: integrity-check/output

steps:
  gatk-VQSR-indel:
    run: gatk-VQSR-indel.cwl
    in:
      input:
        source: input_vcf
      reference:
        source: reference
      prefix:
        source: prefix
      known-sites-indels:
        source: known-sites-indels
      max_gaussians:
        source: max_gaussians
    out: [output]

  gatk-VQSR-snv:
    run: gatk-VQSR-snv.cwl
    in:
      input:
        source: input_vcf
      reference:
        source: reference
      prefix:
        source: prefix
      hapmap:
        source: hapmap
      omni:
        source: omni
      phase:
        source: phase
      known-sites-snp:
        source: known-sites-snp
    out: [output]

  picard-SortVcf:
    run: picard-SortVcf.cwl
    in:
      input_indel:
        source: gatk-VQSR-indel/output
      input_snv:
        source: gatk-VQSR-snv/output
    out: [output]

  integrity-check:
    run: vcf-integrity-check.cwl
    in:
      input:
        source: picard-SortVcf/output
    out: [output]

doc: |
  run VQSR pipeline |
  run an integrity check on the output vcf
