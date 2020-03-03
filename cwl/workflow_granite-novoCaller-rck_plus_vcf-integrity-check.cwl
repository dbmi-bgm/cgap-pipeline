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

  - id: unrelated_index
    type: File
    doc: TSV file containing ID<TAB>Path/to/file for unrelated |
         files used to train the model (rck gz)

  - id: trio_index
    type: File
    doc: TSV file containing ID<TAB>Path/to/file for family |
         files, the PROBAND must be listed as LAST (rck gz)

  - id: ppthr
    type: float
    default: null
    doc: threshold to filter by posterior probability for de novo calls

  - id: aftag
    type: string
    default: null
    doc: TAG (TAG=<float>) to be used to filter by population allele frequency

  - id: afthr
    type: float
    default: null
    doc: threshold to filter by population allele frequency

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
      unrelated_index:
        source: unrelated_index
      trio_index:
        source: trio_index
      ppthr:
        source: ppthr
      aftag:
        source: aftag
      afthr:
        source: afthr
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
