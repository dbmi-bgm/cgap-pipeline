cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: input
    type: File

  - id: rgid
    type: int
    doc: read group ID

  - id: rglb
    type: string
    doc: read group library

  - id: rgpl
    type: string
    doc: read group platform

  - id: rgpu
    type: string
    doc: read group platform unit

  - id: rgsm
    type: int
    doc: read group sample name

  - id: count
    type: int
    default: 0
    doc: 1 count the number of alignments if EOF if present, 0 only check EOF

outputs:
  output:
    type: File
    outputSource: picard-readgroups/output

  output-check:
    type: File
    outputSource: integrity-check/output

steps:
  picard-readgroups:
    run: picard-readgroups.cwl
    in:
      input:
        source: input
      rgid:
        source: rgid
      rglb:
        source: rglb
      rgpl:
        source: rgpl
      rgpu:
        source: rgpu
      rgsm:
        source: rgsm
    out: [output]

  integrity-check:
    run: integrity-check.cwl
    in:
      input:
        source: picard-readgroups/output
      count:
        source: count
    out: [output]

doc: |
  run picard AddOrReplaceReadGroups to mark and assign reads from a .bam input file to a new read group into a output _rg.bam file |
  run an integrity check on the output _rg.bam to confirm an EOF is present and if successful count the number of alignments