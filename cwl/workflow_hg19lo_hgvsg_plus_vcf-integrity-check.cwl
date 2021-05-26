cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: input_vcf
    type: File
    secondaryFiles:
      - .tbi
    doc: expect the path to the sample vcf gz file

  - id: chainfile
    type: File
    doc: expect the path to the hg38-to-hg19-chain file

outputs:
  vcf:
    type: File
    outputSource: hgvsg_creator/output

  vcf-check:
    type: File
    outputSource: integrity-check/output

steps:
  liftover_hg19:
    run: liftover_hg19.cwl
    in:
      input:
        source: input_vcf
      chainfile:
        source: chainfile
    out: [output]

  hgvsg_creator:
    run: hgvsg_creator.cwl
    in:
      input:
        source: liftover_hg19/output
    out: [output]

  integrity-check:
    run: vcf-integrity-check.cwl
    in:
      input:
        source: hgvsg_creator/output
    out: [output]

doc: |
  run liftover_hg19.py to add hg19_chr and hg19_pos data to INFO field for qualified variants |
  run hgvsg_creator.py to add hgvsg data to INFO field for qualified variants |
  run an integrity check on the output vcf gz
