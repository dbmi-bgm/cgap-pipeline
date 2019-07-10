cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: threads
    type: int
    doc: number of threads to use

  - id: reference
    type: File
    secondaryFiles:
      - ^.ann
      - ^.amb
      - ^.pac
      - ^.sa
    doc: expect the path to the .bwt file

  - id: reads_gzipped
    type: File
    doc: reads file gzipped

  - id: mates_gzipped
    type: File
    doc: mate-reads file gzipped

outputs:
  output:
    type: File
    outputSource: sam-to-bam_from_stdout/output

steps:
  gunzip-reads:
    run: gunzip.cwl
    in:
      input:
        source: reads_gzipped
    out: [output]

  gunzip-mates:
    run: gunzip.cwl
    in:
      input:
        source: mates_gzipped
    out: [output]

  bwa-mem_to_stdout:
    run: bwa-mem_to_stdout.cwl
    in:
      threads:
        source: threads

      reference:
        source: reference

      reads:
        source: [gunzip-reads/output, gunzip-mates/output]
    out: [output]

  sam-to-bam_from_stdout:
    run: sam-to-bam_from_stdout.cwl
    in:
      input:
        source: bwa-mem_to_stdout/output
    out: [output]

doc: |
  run bwa mem allowing to specify the number of threads to be used and pipe the output in a .bam output file |
  gunzip the initial FASTQ files
