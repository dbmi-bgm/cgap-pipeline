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

  - id: mti
    type: File
    secondaryFiles:
      - .tbi
      - ^.json
    doc: expect the path to the mutanno index file

  - id: regions
    type: File
    doc: expect the path to the file defining regions

  - id: nthreads
    type: int
    default: 70
    doc: number of threads used to run parallel

  - id: micro_annotation
    type: string
    default: "1"
    doc: whether this is micro-annotation (1) or full annotation (0)

outputs:
  annotated_vcf:
    type: File
    outputSource: mutanno-annot/output

  annotated_vcf-check:
    type: File
    outputSource: integrity-check/output

steps:
  mutanno-annot:
    run: mutanno-annot.cwl
    in:
      input:
        source: input_vcf
      mti:
        source: mti
      regions:
        source: regions
      blocksize:
        source: blocksize
      nthreads:
        source: nthreads
      micro_annotation:
        source: micro_annotation
    out: [output]

  integrity-check:
    run: vcf-integrity-check.cwl
    in:
      input:
        source: mutanno-annot/output
    out: [output]

doc: |
  run mutanno annot |
  run an integrity check on the output vcf
