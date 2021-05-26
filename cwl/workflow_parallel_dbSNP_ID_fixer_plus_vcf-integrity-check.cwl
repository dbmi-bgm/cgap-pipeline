cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: dbSNP_ref_vcf
    type: File
    secondaryFiles:
      - .tbi
    doc: expect the path to the reference dbSNP vcf gz file

  - id: input_vcf
    type: File
    secondaryFiles:
      - .tbi
    doc: expect the path to the sample vcf gz file

  - id: region_file
    type: File
    doc: expect the path to the hg38 region file

  - id: nthreads
    type: int
    default: 2
    doc: number of threads used to run parallel

outputs:
  vcf:
    type: File
    outputSource: parallel_dbSNP_ID_fixer/output

  vcf-check:
    type: File
    outputSource: integrity-check/output

steps:
  parallel_dbSNP_ID_fixer:
    run: parallel_dbSNP_ID_fixer.cwl
    in:
      dbSNP_ref_vcf:
        source: dbSNP_ref_vcf
      input:
        source: input_vcf
      region_file:
        source: region_file
      nthreads:
        source: nthreads
    out: [output]

  integrity-check:
    run: vcf-integrity-check.cwl
    in:
      input:
        source: parallel_dbSNP_ID_fixer/output
    out: [output]

doc: |
  run dbSNP_ID_fixer.py to update sample vcf ID column with rsID(s) |
  run an integrity check on the output vcf gz
