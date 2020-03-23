cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: input_vcf
    type: File
    doc: expect the path to the vcf file

  - id: outputfile
    type: string
    default: "output.vcf"
    doc: name of the output file

  - id: unrelated
    type: File
    secondaryFiles:
      - .index
    doc: expect the rck tar archive with unrelated files used by the model

  - id: trio
    type: File
    secondaryFiles:
      - .index
    doc: expect the rck tar archive with trio files used by the model

  - id: ppthr
    type: float
    default: 0
    doc: threshold to filter by posterior probability for de novo calls

  - id: aftag
    type: string
    default: ''
    doc: TAG (TAG=<float>) to be used to filter by population allele frequency

  - id: afthr
    type: float
    default: 0
    doc: threshold to filter by population allele frequency

  - id: afthr_unrelated
    type: float
    default: 0
    doc: threshold to filter by allele frequency calculated among unrelated

  - id: ADthr
    type: int
    default: 3
    doc: threshold to filter by alternate allele depth in parents

outputs:
  novoCaller_vcf:
    type: File
    outputSource: granite-novoCaller-rck/output

  novoCaller_vcf-check:
    type: File
    outputSource: integrity-check/output

steps:
  granite-novoCaller-rck:
    run: granite-novoCaller-rck.cwl
    in:
      input:
        source: input_vcf
      outputfile:
        source: outputfile
      unrelated:
        source: unrelated
      trio:
        source: trio
      ppthr:
        source: ppthr
      aftag:
        source: aftag
      afthr:
        source: afthr
      afthr_unrelated:
        source: afthr_unrelated
      ADthr:
        source: ADthr
    out: [output]

  integrity-check:
    run: vcf-integrity-check.cwl
    in:
      input:
        source: granite-novoCaller-rck/output
    out: [output]

doc: |
  run granite novoCaller with rck files |
  run an integrity check on the output vcf
