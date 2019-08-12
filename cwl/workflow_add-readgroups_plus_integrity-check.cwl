cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: input_bam
    type: File

  - id: sample_name
    type: string
    doc: sample name

  - id: nthreads
    type: int
    default: 8
    doc: number of threads

  - id: count
    type: int
    default: 0
    doc: 1 count the number of alignments if EOF if present, 0 only check EOF

outputs:
  bam_w_readgroups:
    type: File
    outputSource: add-readgroups/output

  bam_w_readgroups-check:
    type: File
    outputSource: integrity-check/output

steps:
  add-readgroups:
    run: add-readgroups.cwl
    in:
      input:
        source: input_bam
      sample_name:
        source: sample_name
      nthreads:
        source: nthreads
    out: [output]

  integrity-check:
    run: integrity-check.cwl
    in:
      input:
        source: add-readgroups/output
      count:
        source: count
    out: [output]

doc: |
  run AddReadGroups.py to mark and assign reads from a bam input file to new read groups |
  run an integrity check on the output bam to confirm an EOF is present and if successful count the number of alignments
