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

  - id: bqsr
    type: File
    doc: expect the path to the recalibration_report

  - id: static-quantized-quals_1
    type: int

  - id: static-quantized-quals_2
    type: int

  - id: static-quantized-quals_3
    type: int

  - id: count
    type: int
    doc: 1 count the number of alignments if EOF if present, 0 only check EOF

outputs:
  output:
    type: File
    outputSource: gatk-ApplyBQSR/output

  output-check:
    type: File
    outputSource: integrity-check/output

steps:
  gatk-ApplyBQSR:
    run: gatk-ApplyBQSR.cwl
    in:
      input:
        source: input
      reference:
        source: reference
      bqsr:
        source: bqsr
      static-quantized-quals_1:
        source: static-quantized-quals_1
      static-quantized-quals_2:
        source: static-quantized-quals_2
      static-quantized-quals_3:
        source: static-quantized-quals_3
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
