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

outputs:
  merged_bam:
    type: File
    outputSource: merge_bam/merged_bam

  merged_bam-check:
    type: File
    outputSource: integrity-check/output

steps:
  merge_bam:
    run: merge_bam.cwl
    in:
      input_bams:
        source: input_bams
      reads_grouped_by_name:
        source: reads_grouped_by_name
    out: [merged_bam]

  integrity-check:
    run: integrity-check.cwl
    in:
      input:
        source: merge_bam/merged_bam
      count:
        source: count
    out: [output]

doc: |
  run samtools merge -c -p merged.bam in1.bam in2.bam ... |
  run an integrity check on the output merged_bam to confirm an EOF is present and if successful count the number of alignments
