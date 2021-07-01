#!/usr/bin/env python3

################################################
#
#
#
#   Michele Berselli
#   berselli.michele@gmail.com
#
################################################

################################################
#   Libraries
################################################
import sys, os
from magma_ff.metawflrun import MetaWorkflowRun
from magma_ff import wfrutils
from dcicutils import ff_utils

################################################
#   Variables
################################################
steps_dict = {
    # BAM
    'workflow_add-readgroups-check': {
                        'dependency': 'workflow_bwa-mem_no_unzip-check',
                        'output': 'bam_w_readgroups',
                        'output_match': 'raw_bam',
                        'key': 'Total Reads',
                        'key_match': 'Total Reads'
                        },
    'workflow_merge-bam-check': {
                        'dependency': 'workflow_add-readgroups-check',
                        'output': 'merged_bam',
                        'output_match': 'bam_w_readgroups',
                        'key': 'Total Reads',
                        'key_match': 'Total Reads'
                        },
    'workflow_picard-MarkDuplicates-check':{
                        'dependency': 'workflow_merge-bam-check',
                        'output': 'dupmarked_bam',
                        'output_match': 'merged_bam',
                        'key': 'Total Reads',
                        'key_match': 'Total Reads'
                        },
    'workflow_sort-bam-check': {
                        'dependency': 'workflow_picard-MarkDuplicates-check',
                        'output': 'sorted_bam',
                        'output_match': 'dupmarked_bam',
                        'key': 'Total Reads',
                        'key_match': 'Total Reads'
                        },
    'workflow_gatk-ApplyBQSR-check': {
                        'dependency': 'workflow_sort-bam-check',
                        'output': 'recalibrated_bam',
                        'output_match': 'sorted_bam',
                        'key': 'Total Reads',
                        'key_match': 'Total Reads'
                        },
    # VCF
    'workflow_samplegeno': {
                         'dependency': 'workflow_gatk-GenotypeGVCFs-check',
                         'output': 'samplegeno_vcf',
                         'output_match': 'vcf',
                         'key': 'Filtered Variants',
                         'key_match': 'Filtered Variants'
                         },
    # 'workflow_vep-annot-check': {
    #                      'dependency': 'workflow_samplegeno',
    #                      'output': 'annotated_vcf',
    #                      'output_match': 'samplegeno_vcf',
    #                      'key': 'Total Variants Called',
    #                      'key_match': 'Filtered Variants'
    #                      },
    'workflow_granite-comHet-check': {
                         'dependency': 'workflow_granite-filtering-check',
                         'output': 'comHet_vcf',
                         'output_match': 'merged_vcf',
                         'key': 'Filtered Variants',
                         'key_match': 'Filtered Variants'
                         },
    'workflow_dbSNP_ID_fixer-check': {
                         'dependency': 'workflow_granite-comHet-check',
                         'output': 'vcf',
                         'output_match': 'comHet_vcf',
                         'key': 'Filtered Variants',
                         'key_match': 'Filtered Variants'
                         },
    'workflow_hg19lo_hgvsg-check': {
                         'dependency': 'workflow_dbSNP_ID_fixer-check',
                         'output': 'vcf',
                         'output_match': 'vcf',
                         'key': 'Filtered Variants',
                         'key_match': 'Filtered Variants'
                         }
    }

fastqs_dict = {
    'workflow_bwa-mem_no_unzip-check': {
                         'output': 'raw_bam',
                         'input_match': ['fastq_R1', 'fastq_R2'],
                         'key': 'Total Reads',
                         'key_match': 'Total Sequences'
                         }
}

################################################
#   Functions
################################################
################################################
#   check_lines
################################################
def check_lines(metawfr_uuid, ff_key, steps=steps_dict, fastqs=fastqs_dict):
    """
    """
    print('Meta Workflow:')
    print(' -> ' + metawfr_uuid + '\n')

    # Get meta-workflow-run and create MetaWorkflowRun object
    run_json = ff_utils.get_metadata(metawfr_uuid, add_on='?frame=raw&datastore=database', key=ff_key)
    metawflrun_obj = MetaWorkflowRun(run_json)

    is_match = True
    # Check fastqs
    for _, run_obj in metawflrun_obj.runs.items():
        count, match_count = 0, 0
        if run_obj.name in fastqs:
            if run_obj.status == 'completed':
                # Get output count
                for output in run_obj.output:
                    if output['argument_name'] == fastqs[run_obj.name]['output']:
                        output_uuid = output['file']
                        qc_key = fastqs[run_obj.name]['key']
                        count = int(get_count_qc(qc_key, output_uuid, ff_key))
                        break
                    #end if
                #end for
                print('Shard:')
                print(' -> ' + run_obj.shard_name + ', ' + str(count))

                # Get input file to match from jobid
                print('File/s to match:')
                ffwr_obj = wfrutils.FFWfrUtils(env='env')
                ffwr_obj._ff_key = ff_key
                file_match = True
                for file in ffwr_obj.wfr_metadata(run_obj.jobid)['input_files']:
                    if file['workflow_argument_name'] in fastqs[run_obj.name]['input_match']:
                        input_uuid = file['value']['uuid']
                        qc_key = fastqs[run_obj.name]['key_match']
                        match_count = int(get_count_fastqc(qc_key, input_uuid, ff_key))
                        if not count == match_count:
                            is_match = False
                            file_match = False
                        #end if
                        print(' -> ' + file['workflow_argument_name'] + ', ' + str(match_count))
                    #end if
                #end for
                print('Matching: ' + str(file_match) + '\n')
            else:
                print('Missing: ' + run_obj.name + '\n')
                print('Completed: False\n')
                return False
            #end if
        #end if
    #end for

    # Check steps
    for _, run_obj in metawflrun_obj.runs.items():
        count, total_count = 0, 0
        if run_obj.name in steps:
            if run_obj.status == 'completed':
                # Get output count
                for output in run_obj.output:
                    if output['argument_name'] == steps[run_obj.name]['output']:
                        output_uuid = output['file']
                        qc_key = steps[run_obj.name]['key']
                        count = int(get_count_qc(qc_key, output_uuid, ff_key))
                        break
                    #end if
                #end for
                print('Shard:')
                print(' -> ' + run_obj.shard_name + ', ' + str(count))

                # Get dependencies count
                print('Shard/s to match (sum):')
                for shard_name in run_obj.dependencies:
                    if shard_name.split(':')[0] == steps[run_obj.name]['dependency']:
                        run_obj_ = metawflrun_obj.runs[shard_name]
                        for output in run_obj_.output:
                            if output['argument_name'] == steps[run_obj.name]['output_match']:
                                output_uuid = output['file']
                                qc_key = steps[run_obj.name]['key_match']
                                count_ = int(get_count_qc(qc_key, output_uuid, ff_key))
                                total_count += count_
                                break
                            #end if
                        #end for
                        print(' -> ' + shard_name + ', ' + str(count_))
                    #end if
                #end for
                print('Matching: ' + str(count == total_count) + '\n')
                # Check counts match
                if not count == total_count:
                    is_match = False
                #end if
            else:
                print('Missing: ' + run_obj.name + '\n')
                print('Completed: False\n')
                return False
            #end if
        #end if
    #end for
    print('Completed: ' + str(is_match) + '\n')
    return is_match
#end def

def get_count_qc(qc_key, uuid, ff_key):
    """
    """
    try:
        res_json = ff_utils.get_metadata(uuid, add_on='?frame=raw&datastore=database', key=ff_key)
        qc_uuid = res_json['quality_metric']
        qc_json = ff_utils.get_metadata(qc_uuid, add_on='?datastore=database', key=ff_key)
        for qc in qc_json['quality_metric_summary']:
            if qc['title'] == qc_key:
                return qc['value']
            #end if
        #end for
    except KeyError:
        return 0
    #end try
#end def

def get_count_fastqc(qc_key, uuid, ff_key):
    """
    """
    try:
        res_json = ff_utils.get_metadata(uuid, add_on='?frame=raw&datastore=database', key=ff_key)
        qc_uuid = res_json['quality_metric']
        qc_json = ff_utils.get_metadata(qc_uuid, add_on='?datastore=database', key=ff_key)
        return qc_json[qc_key]
    except KeyError:
        return 0
    #end try
#end def
