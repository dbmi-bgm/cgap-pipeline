=================
Adding SAMPLEGENO
=================

This step is for portal compatibility, and can be skipped for non-portal use cases. The tag SAMPLEGENO is added to the INFO field during this step. The main purposes of this step are:

- To have a place for accessing the genotypes and AD information for all the samples in one place
- To keep the information about the original genotypes and ADs before splitting multi-allelic variants

This step is run prior to the multi-allelic splitting carried out in the VEP workflow.

- CWL: samplegeno.cwl
