=======================
CGAP pipeline utilities
=======================

Functions
*********

check_lines
^^^^^^^^^^^
*check_lines* function can be used to check that line counts are matching between two steps output, or between a output bam and the input fastq files.
Requires uuid for the MetaWorkflowRun object to check and ff_key to access the metadata on the portal. The steps to compare are specified as dictionaries, examples below.

.. code-block:: python

    from pipeline_utils.check_lines import *

    res = check_lines(metawfr_uuid, ff_key, steps=steps_dict, fastqs=fastqs_dict)

    ## steps_dict example
    # steps_dict = {
    #     'workflow_add-readgroups-check': {
    #                         'dependency': 'workflow_bwa-mem_no_unzip-check',
    #                         'output': 'bam_w_readgroups',
    #                         'output_match': 'raw_bam',
    #                         'key': 'Total Reads',
    #                         'key_match': 'Total Reads'
    #                         },
    #     ...
    # }

    ## fastqs_dict example
    # fastqs_dict = {
    #     'workflow_bwa-mem_no_unzip-check': {
    #                          'output': 'raw_bam',
    #                          'input_match': ['fastq_R1', 'fastq_R2'],
    #                          'key': 'Total Reads',
    #                          'key_match': 'Total Sequences'
    #                          },
    #     ...
    # }
