=======================
Novel indels annotation
=======================

This step extracts and annotates indels from the input vcf file. ``vep`` is used for annotation and ``mutanno preprocess`` is used to create source files for subsequent annotation steps.

This step is necessary to create additional sources of annotation for novel indels that are missing in the main annotation source.


* CWL: vep-parallel.cwl
