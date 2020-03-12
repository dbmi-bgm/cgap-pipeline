cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: cram
    type: File
    doc: input cram file

  - id: reference_fasta
    type:
      - File
      - "null"
    secondaryFiles:
      - .fai
    doc: reference fasta file

  - id: reference_md5_list
    type:
      - File
      - "null"
    doc: file containing the list of md5 for the reference chromosomes

  - id: out_prefix
    type: string
    default: "out"
    doc: prefix of the output file

  - id: nthreads
    type: int
    default: 8
    doc: number of threads to be used

  - id: count
    type: int
    default: 0
    doc: 1 count the number of alignments if EOF if present, 0 only check EOF

outputs:
  converted_bam:
    type: File
    outputSource: cram2bam/converted_bam

  converted_bam-check:
    type: File
    outputSource: integrity-check/output

steps:
  cram2bam:
    run: cram2bam.cwl
    in:
      cram:
        source: cram
      reference_fasta:
        source: reference_fasta
      reference_md5_list:
        source: reference_md5_list
      out_prefix:
        source: out_prefix
      nthreads:
        source: nthreads
    out: [converted_bam]

  integrity-check:
    run: integrity-check.cwl
    in:
      input:
        source: cram2bam/converted_bam
      count:
        source: count
    out: [output]

doc: |
  convert cram to bam allowing to specify the number of threads to be used and ensuring to use the same reference fasta as the one used in cram |
  run an integrity check on the output bam to confirm an EOF is present and if successful count the number of alignments
