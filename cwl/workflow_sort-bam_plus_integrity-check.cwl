cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: max_memory
    type: string
    default: '3G'
    doc: maximum required memory per thread

  - id: nthreads
    type: int
    default: 8
    doc: number of sorting and compression threads

  - id: input_bam
    type: File

  - id: count
    type: int
    default: 0
    doc: 1 count the number of alignments if EOF if present, 0 only check EOF

outputs:
  sorted_bam:
    type: File
    outputSource: sort-bam/output

  sorted_bam-check:
    type: File
    outputSource: integrity-check/output

steps:
  sort-bam:
    run: sort-bam.cwl
    in:
      max_memory:
        source: max_memory
      nthreads:
        source: nthreads
      input:
        source: input_bam
    out: [output]

  integrity-check:
    run: integrity-check.cwl
    in:
      input:
        source: sort-bam/output
      count:
        source: count
    out: [output]

doc: |
  run samtools sort to sort input bam file |
  run an integrity check on the output bam to confirm an EOF is present and if successful count the number of alignments
