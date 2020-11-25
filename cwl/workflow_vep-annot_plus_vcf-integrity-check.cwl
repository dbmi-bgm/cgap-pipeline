cwlVersion: v1.0

class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  - id: input_vcf
    type: File
    secondaryFiles:
      - .tbi
    doc: expect the path to the vcf gz file

  - id: reference
    type: File
    secondaryFiles:
      - ^.dict
      - .fai
    doc: expect the path to the fa reference file

  - id: regions
    type: File
    doc: expect the path to the file defining regions

  - id: vep
    type: File
    secondaryFiles:
      - ^^^.plugins.tar.gz
    doc: expect the path to the vep tar gz

  - id: clinvar
    type: File
    secondaryFiles:
      - .tbi
    doc: expect the path to the vcf gz file with Clinvar annotations

  - id: dbnsfp
    type: File
    secondaryFiles:
      - .tbi
      - ^.readme.txt
    doc: expect the path to the vcf gz file with dbNSFP annotations

  - id: maxent
    type: File
    doc: expect the path to the fordownload tar gz

  - id: spliceai_snv
    type: File
    secondaryFiles:
      - .tbi
    doc: expect the path to the vcf gz file with SpliceAI for SNVs

  - id: spliceai_indel
    type: File
    secondaryFiles:
      - .tbi
    doc: expect the path to the vcf gz file with SpliceAI for indels

  - id: gnomad
    type: File
    secondaryFiles:
      - .tbi
    doc: expect the path to the vcf gz file with gnomAD annotations

  - id: nthreads
    type: int
    default: 50
    doc: number of threads used to run parallel

  - id: version
    type: string
    default: "101"
    doc: vep datasource version

  - id: assembly
    type: string
    default: "GRCh38"
    doc: genome assembly version

outputs:
  annotated_vcf:
    type: File
    outputSource: vep-annot/output

  annotated_vcf-check:
    type: File
    outputSource: integrity-check/output

steps:
  bcftools-norm-multiallelics:
    run: bcftools-norm-multiallelics.cwl
    in:
      input:
        source: input_vcf
    out: [output]

  vep-annot:
    run: vep-annot.cwl
    in:
      input:
        source: bcftools-norm-multiallelics/output
      reference:
        source: reference
      regions:
        source: regions
      vep:
        source: vep
      clinvar:
        source: clinvar
      dbnsfp:
        source: dbnsfp
      maxent:
        source: maxent
      spliceai_snv:
        source: spliceai_snv
      spliceai_indel:
        source: spliceai_indel
      gnomad:
        source: gnomad
      nthreads:
        source: nthreads
      version:
        source: version
      assembly:
        source: assembly
    out: [output]

  integrity-check:
    run: vcf-integrity-check.cwl
    in:
      input:
        source: vep-annot/output
    out: [output]

doc: |
  run vep |
  run an integrity check on the output vcf
