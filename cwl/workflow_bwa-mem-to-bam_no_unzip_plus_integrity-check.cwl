cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: fastq_R1
    type: File
    doc: reads file

  - id: fastq_R2
    type: File
    doc: mate-reads file

  - id: reference
    type: File
    secondaryFiles:
      - ^.ann
      - ^.amb
      - ^.pac
      - ^.sa
      - ^.alt
    doc: expect the path to the bwt file

  - id: outdir
    type: string
    default: "."
    doc: output directory

  - id: prefix
    type: string
    default: "raw"
    doc: prefix of the output file

  - id: nthreads
    type: int
    default: 72
    doc: number of threads to be used

  - id: count
    type: int
    default: 0
    doc: 1 count the number of alignments if EOF if present, 0 only check EOF

outputs:
  raw_bam:
    type: File
    outputSource: bwa-mem-to-bam_no_unzip/output

  raw_bam-check:
    type: File
    outputSource: integrity-check/output

steps:
  bwa-mem-to-bam_no_unzip:
    run: bwa-mem-to-bam_no_unzip.cwl
    in:
      fastq_R1:
        source: fastq_R1
      fastq_R2:
        source: fastq_R2
      reference:
        source: reference
      outdir:
        source: outdir
      prefix:
        source: prefix
      nthreads:
        source: nthreads
    out: [output]

  integrity-check:
    run: integrity-check.cwl
    in:
      input:
        source: bwa-mem-to-bam_no_unzip/output
      count:
        source: count
    out: [output]

doc: |
  run bwa mem allowing to specify the number of threads to be used and pipe the output in a bam output file |
  expect the fastq files already unzipped |
  run an integrity check on the output bam to confirm an EOF is present and if successful count the number of alignments
