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

  - id: min_depth
    type: int
    default: 3
    doc: expect the minimum DP (depth) value for a given variant, at least 1 sample must have DP >= min_depth to keep a variant

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

  - id: gnomad2
    type: File
    secondaryFiles:
      - .tbi
    doc: expect the path to the vcf gz file with gnomAD v2.1 exome annotations

  - id: CADD_snv
    type: File
    secondaryFiles:
      - .tbi
    doc: expect the path to the tsv gz file with CADD Phred annotations for SNVs

  - id: CADD_indel
    type: File
    secondaryFiles:
      - .tbi
    doc: expect the path to the tsv gz file with CADD Phred annotations for indels

  - id: phylop100bw
    type: File
    doc: expect the path to the bw file with phyloP 100-way vertebrate conservation scores

  - id: phylop30bw
    type: File
    doc: expect the path to the bw file with phyloP 30-way mammalian conservation scores

  - id: phastc100bw
    type: File
    doc: expect the path to the bw file with PhastCons 100-way vertebrate conservation scores

  - id: nthreads
    type: int
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
      reference:
        source: reference
    out: [output]

  depth_filter:
      run: depth_filter.cwl
      in:
        input:
          source: bcftools-norm-multiallelics/output
        min_depth:
          source: min_depth
      out: [output]

  vep-annot:
    run: vep-annot.cwl
    in:
      input:
        source: depth_filter/output
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
      gnomad2:
        source: gnomad2
      CADD_snv:
        source: CADD_snv
      CADD_indel:
        source: CADD_indel
      phylop100bw:
        source: phylop100bw
      phylop30bw:
        source: phylop30bw
      phastc100bw:
        source: phastc100bw
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
  run bcftools-norm-multiallelics |
  run depth_filter |
  run vep |
  run an integrity check on the output vcf
