cwlVersion: v1.0

class: Workflow

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

  - id: reads
    type:
      type: array
      items: File
    doc: reads file and mate-reads file as an array

outputs:
  output:
    type: File
    outputSource: sam-to-bam_from_stdout/output

steps:
  bwa-mem_to_stdout:
    run: bwa-mem_to_stdout.cwl
    in:
      threads:
        source: threads

      reference:
        source: reference

      reads:
        source: reads
    out: [output]

  sam-to-bam_from_stdout:
    run: sam-to-bam_from_stdout.cwl
    in:
      input:
        source: bwa-mem_to_stdout/output
    out: [output]

doc: |
  run bwa mem allowing to specify the number of threads to be used and pipe the output in a .bam output file
