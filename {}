cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: input_bam
    type: File

  - id: xmx
    default: '160G'
    type: string

  - id: xms
    default: '160G'
    type: string

  - id: max_records_in_ram
    type: int
    default: 2000000
    doc: max number of records stored in RAM before spilling to disk

  - id: duplicate_pixel_distance
    type: int
    default: 2500
    doc: max offset between two duplicate clusters in order to consider them optical duplicates

  - id: count
    type: int
    default: 0
    doc: 1 count the number of alignments if EOF if present, 0 only check EOF

outputs:
  dupmarked_bam:
    type: File
    outputSource: picard-MarkDuplicates/output

  duplicate_metrics:
    type: File
    outputSource: picard-MarkDuplicates/out_metrics

  dupmarked_bam-check:
    type: File
    outputSource: integrity-check/output

steps:
  picard-MarkDuplicates:
    run: picard-MarkDuplicates.cwl
    in:
      input:
        source: input_bam
      xmx:
        source: xmx
      xms:
        source: xms
      max_records_in_ram:
        source: max_records_in_ram
      duplicate_pixel_distance:
        source: duplicate_pixel_distance
    out: [output, out_metrics]

  integrity-check:
    run: integrity-check.cwl
    in:
      input:
        source: picard-MarkDuplicates/output
      count:
        source: count
    out: [output]

doc: |
  run picard MarkDuplicates to mark the duplicates in the input bam file |
  generate a duplicate_metrics.txt file with metrics about duplicates identified |
  run an integrity check on the output bam to confirm an EOF is present and if successful count the number of alignments
