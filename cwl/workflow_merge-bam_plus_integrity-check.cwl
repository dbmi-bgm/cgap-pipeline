cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: input_bams
    type:
      -
        type: array
        items: File
    doc: input bam files

  - id: reads_grouped_by_name
    type: boolean
    default: true
    doc: reads are grouped by name

  - id: count
    type: int
    default: 0
    doc: whether read count is checked at the end

  - id: nthreads
    type: int
    default: 8
    doc: number of sorting and compression threads

outputs:
  merged_bam:
    type: File
    outputSource: merge-bam/output

  merged_bam-check:
    type: File
    outputSource: integrity-check/output

steps:
  merge-bam:
    run: merge-bam.cwl
    in:
      input_bams:
        source: input_bams
      reads_grouped_by_name:
        source: reads_grouped_by_name
      nthreads:
        source: nthreads
    out: [output]

  integrity-check:
    run: integrity-check.cwl
    in:
      input:
        source: merge-bam/output
      count:
        source: count
    out: [output]

doc: |
  run samtools merge -@ nthreads -c -p merged.bam in1.bam in2.bam ... |
  run an integrity check on the output bam to confirm an EOF is present and if successful count the number of alignments
