cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: max_memory
    type: string
    doc: maximum required memory per thread

  - id: num_threads
    type: int
    doc: number of sorting and compression threads

  - id: input
    type: File

  - id: count
    type: string

outputs:
  output:
    type: File
    outputSource: sort-bam/output

  output-check:
    type: File
    outputSource: integrity-check/output

steps:
  sort-bam:
    run: sort-bam.cwl
    in:
      max_memory:
        source: max_memory
      num_threads:
        source: num_threads
      input:
        source: input
    out: [output]

  integrity-check:
    run: integrity-check.cwl
    in:
      input:
        source: sort-bam/output
      count:
        source: count
    out: [output]

doc: |
  run samtools sort to sort input .bam file into _sorted.bam output file |
  run an integrity check on the output _sorted.bam to confirm an EOF is present and if successful count the number of reads
