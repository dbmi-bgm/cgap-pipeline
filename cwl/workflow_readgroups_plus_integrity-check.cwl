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
    outputSource: readgroups/bam_w_readgroups

  output-check:
    type: File
    outputSource: integrity-check/output

steps:
  readgroups:
    run: readgroups.cwl
    in:
      input_bam:
        source: input_bam
      sample_name:
        source: sample_name
      nthreads:
        source: nthreads
    out: [bam_w_readgroups]

  integrity-check:
    run: integrity-check.cwl
    in:
      input:
        source: readgroups/bam_w_readgroups
      count:
        source: count
    out: [output]

doc: |
  run AddReadGroups.py to mark and assign reads from a .bam input file to a new read group into a output _rg.bam file |
  run an integrity check on the output _rg.bam to confirm an EOF is present and if successful count the number of alignments
