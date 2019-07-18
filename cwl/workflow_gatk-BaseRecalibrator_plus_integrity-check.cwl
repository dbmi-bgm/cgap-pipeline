cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: input
    type: File
    doc: input file .bam

  - id: reference
    type: File
    secondaryFiles:
      - ^.dict
      - .fai
    doc: expect the path to the .fa file

  - id: known-sites-snp
    type: File
    secondaryFiles:
      - .tbi
    doc: expect the path to the dbsnp .vcf.gz file

  - id: known-sites-indels
    type: File
    secondaryFiles:
      - .idx
    doc: expect the path to the indel .vcf file

outputs:
  output:
    type: File
    outputSource: gatk-BaseRecalibrator/output

  output-check:
    type: File
    outputSource: integrity-check/output

steps:
  gatk-BaseRecalibrator:
    run: gatk-BaseRecalibrator.cwl
    in:
      input:
        source: input
      reference:
        source: reference
      known-sites-snp:
        source: known-sites-snp
      known-sites-indels:
        source: known-sites-indels
    out: [output]

  integrity-check:
    run: integrity-check.cwl
    in:
      input:
        source: gatk-BaseRecalibrator/output
    out: [output]

doc: |
  run gatk BaseRecalibrator |
  run an integrity check on the output to confirm an EOF is present and if successful count the number of reads
