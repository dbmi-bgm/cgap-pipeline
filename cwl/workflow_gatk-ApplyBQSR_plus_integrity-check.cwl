cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: input_bam
    type: File
    doc: input file

  - id: reference
    type: File
    secondaryFiles:
      - ^.dict
      - .fai
    doc: expect the path to the fa file

  - id: recalibration_report
    type: File
    doc: expect the path to the recalibration_report

  - id: static-quantized-quals_1
    type: int
    default: 10

  - id: static-quantized-quals_2
    type: int
    default: 20

  - id: static-quantized-quals_3
    type: int
    default: 30

  - id: nthreads
    type: int
    default: 28
    doc: number of threads used to run parallel

  - id: count
    type: int
    default: 0
    doc: 1 count the number of alignments if EOF if present, 0 only check EOF

outputs:
  recalibrated_bam:
    type: File
    outputSource: gatk-ApplyBQSR/output

  recalibrated_bam-check:
    type: File
    outputSource: integrity-check/output

steps:
  gatk-ApplyBQSR:
    run: gatk-ApplyBQSR.cwl
    in:
      input:
        source: input_bam
      reference:
        source: reference
      bqsr:
        source: recalibration_report
      static-quantized-quals_1:
        source: static-quantized-quals_1
      static-quantized-quals_2:
        source: static-quantized-quals_2
      static-quantized-quals_3:
        source: static-quantized-quals_3
      nthreads:
        source: nthreads
    out: [output]

  integrity-check:
    run: integrity-check.cwl
    in:
      input:
        source: gatk-ApplyBQSR/output
      count:
        source: count
    out: [output]

doc: |
  run gatk ApplyBQSR |
  run an integrity check on the output to confirm an EOF is present and if successful count the number of alignments
