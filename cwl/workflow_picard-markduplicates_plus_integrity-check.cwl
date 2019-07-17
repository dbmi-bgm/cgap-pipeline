cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: input
    type: File

  - id: xmx
    type: string

  - id: xms
    type: string

  - id: max_records_in_ram
    type: int
    doc: max number of records stored in RAM before spilling to disk

  - id: duplicate_pixel_distance
    type: int
    doc: max offset between two duplicate clusters in order to consider them optical duplicates

outputs:
  output:
    type: File
    outputSource: picard-markduplicates/output

  out_metrics:
    type: File
    outputSource: picard-markduplicates/out_metrics

  output-check:
    type: File
    outputSource: integrity-check/output

steps:
  picard-markduplicates:
    run: picard-markduplicates.cwl
    in:
      input:
        source: input
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
        source: picard-markduplicates/output
    out: [output]

doc: |
  run picard MarkDuplicates to mark the duplicates in the input .bam file into a new _rm.bam output file |
  generate a duplicate_metrics.txt file with metrics about duplicates identified |
  run an integrity check on the output _rm.bam to confirm an EOF is present and if successful count the number of reads
