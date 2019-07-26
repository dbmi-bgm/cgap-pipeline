cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: reads_unzipped
    type: File
    doc: reads file

  - id: mates_unzipped
    type: File
    doc: mate-reads file

  - id: reference
    type: File
    secondaryFiles:
      - ^.ann
      - ^.amb
      - ^.pac
      - ^.sa
    doc: expect the path to the .bwt file

  - id: outdir
    type: string
    doc: output directory

  - id: prefix
    type: string
    doc: prefix of the output file

  - id: threads
    type: int
    doc: number of threads to be used

outputs:
  output:
    type: File
    outputSource: bwa-mem-to-bam_no_unzip/output

  output-check:
    type: File
    outputSource: integrity-check/output

steps:
  bwa-mem-to-bam_no_unzip:
    run: bwa-mem-to-bam_no_unzip.cwl
    in:
      reads_unzipped:
        source: reads_unzipped
      mates_unzipped:
        source: mates_unzipped
      reference:
        source: reference
      outdir:
        source: outdir
      prefix:
        source: prefix
      threads:
        source: threads
    out: [output]

  integrity-check:
    run: integrity-check.cwl
    in:
      input:
        source: bwa-mem-to-bam_no_unzip/output
    out: [output]

doc: |
  run bwa mem allowing to specify the number of threads to be used and pipe the output in a .bam output file |
  expect the fastq files already unzipped |
  run an integrity check on the output .bam to confirm an EOF is present and if successful count the number of reads
