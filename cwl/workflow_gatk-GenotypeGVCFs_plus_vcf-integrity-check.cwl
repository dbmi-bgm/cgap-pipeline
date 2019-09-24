cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: input_gvcf
    type: File
    secondaryFiles:
      - .tbi
    doc: expect the path to the gvcf gz file

  - id: reference
    type: File
    secondaryFiles:
      - .fai
      - ^.dict
    doc: expect the path to the fa file

  - id: known-sites-snp
    type: File
    secondaryFiles:
      - .idx
    doc: expect the path to the dbsnp vcf file

  - id: verbosity
    type: string
    default: INFO

outputs:
  vcf:
    type: File
    outputSource: gatk-GenotypeGVCFs/output

  vcf-check:
    type: File
    outputSource: integrity-check/output

steps:
  gatk-GenotypeGVCFs:
    run: gatk-GenotypeGVCFs.cwl
    in:
      input:
        source: input_gvcf
      reference:
        source: reference
      known-sites-snp:
        source: known-sites-snp
      verbosity:
        source: verbosity
    out: [output]

  integrity-check:
    run: vcf-integrity-check.cwl
    in:
      input:
        source: gatk-GenotypeGVCFs/output
    out: [output]

doc: |
  run gatk GenotypeGVCFs |
  run an integrity check on the output vcf
