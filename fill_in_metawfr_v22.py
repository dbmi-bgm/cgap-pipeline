import json
import copy
import uuid
from magma import metawfl
from magma_ff import parser
from dcicutils import ff_utils

# ff_key = ff_utils.get_authentication_with_server(ff_env='fourfront-cgapwolf')
# case_uuid = '1ea344bc-e211-4b11-8bde-7b94dadda7e2'  # NA12879
# metawfr_uuid = '6ce6158e-4283-4b28-aa0d-4b7b2e6e23cb'

ff_key = ff_utils.get_authentication_with_server(ff_env='fourfront-cgap')
case_uuid = '81278096-7c10-4c5a-8ac3-5e3014e83bbb'  # NA12879 on cgap
metawfr_uuid = 'b08760e4-3f5d-475b-be0f-b7c4e5a71e61'


def fill_in_metawfr_with_existing_wfrs(metawfr_uuid, case_uuid, fastq_order=1, patch=False):
    metawfr_meta = ff_utils.get_metadata(metawfr_uuid, add_on='?frame=raw', key=ff_key)

    def fill_in(wfr_name, wfr_meta, file_uuid, shard=None, arg_name=None):
        """file_uuid is the output of wfr. wfr_meta is the metadata for the wfr.
        wfr_name is the name matching the one in the MetaWorkflowRun."""
        for wfr in metawfr_meta['workflow_runs']:
            if wfr['name'] == wfr_name and (not shard or wfr['shard'] == shard):
                if wfr_meta:
                    wfr['workflow_run'] = wfr_meta['uuid']
                    wfr['jobid'] = wfr_meta['awsem_job_id']
                    wfr['status'] = 'completed' if wfr_meta['run_status'] == 'complete' else 'failed'
                    if file_uuid:
                        for opf in wfr_meta['output_files']:
                            if opf['value'] == file_uuid:
                                arg_name = opf['workflow_argument_name']
                                break
                        wfr['output'] = [{'file': file_uuid, 'argument_name': arg_name}]
                else:  # skipped case
                    wfr['status'] = 'completed'
                    if file_uuid:
                        wfr['output'] = [{'file': file_uuid, 'argument_name': arg_name}]

    case_meta = ff_utils.get_metadata(case_uuid, add_on='?frame=raw', key=ff_key)
    sp_uuid = case_meta['sample_processing']
    sp_meta = ff_utils.get_metadata(sp_uuid, add_on='?frame=object', key=ff_key)

    if 'processed_files' not in sp_meta:
        raise Exception("can't fine processed files on sample processing.")
    last_pf_id = sp_meta['processed_files'][1]
    last_pf_meta = ff_utils.get_metadata(last_pf_id, add_on='?frame=object', key=ff_key)

    # sanity check
    if last_pf_meta['file_format'] != '/file-formats/vcf_gz/':
        raise Exception("Error: last processed file format is not vcf.")

    last_pf_wfr_id = last_pf_meta['workflow_run_outputs'][0]
    last_pf_wfr_meta = ff_utils.get_metadata(last_pf_wfr_id, add_on='?frame=raw', key=ff_key)

    if not last_pf_wfr_meta['title'].startswith('workflow_hg19lo_hgvsg-check v22'):
            raise Exception("Error: last processed file workflow rub is not workflow_hg19lo_hgvsg-check.")

    # workflow_hg19lo_hgvsg-check
    fill_in('workflow_hg19lo_hgvsg-check', last_pf_wfr_meta, last_pf_meta['uuid'])

    # workflow_granite-qcVCF-2 and bamsnap
    for wfri_id in last_pf_meta['workflow_run_inputs']:
        wfri_meta = ff_utils.get_metadata(wfri_id, add_on='?frame=raw', key=ff_key)
        if wfri_meta['awsem_app_name'] == 'workflow_granite-qcVCF' and wfri_meta['run_status'] == 'complete':
            fill_in('workflow_granite-qcVCF-2', wfri_meta, None)
        elif wfri_meta['awsem_app_name'] == 'bamsnap' and wfri_meta['run_status'] == 'complete':
            fill_in('bamsnap', wfri_meta, None)

    # workflow_dbSNP_ID_fixer-check
    for ipf in last_pf_wfr_meta['input_files']:
        if ipf['workflow_argument_name'] == 'input_vcf':
            prev_file_uuid = ipf['value']
            break
    prev_file_meta = ff_utils.get_metadata(prev_file_uuid, add_on='?frame=object', key=ff_key)
    prev_wfr_id = prev_file_meta['workflow_run_outputs'][0]
    prev_wfr_meta = ff_utils.get_metadata(prev_wfr_id, add_on='?frame=raw', key=ff_key)

    fill_in(prev_wfr_meta['awsem_app_name'], prev_wfr_meta, prev_file_meta['uuid'])

    # workflow_granite-comHet-check
    prev_file_uuid = ''
    for ipf in prev_wfr_meta['input_files']:
        if ipf['workflow_argument_name'] == 'input_vcf':
            prev_file_uuid = ipf['value']
            break
    prev_file_meta = ff_utils.get_metadata(prev_file_uuid, add_on='?frame=object', key=ff_key)
    prev_wfr_id = prev_file_meta['workflow_run_outputs'][0]
    prev_wfr_meta = ff_utils.get_metadata(prev_wfr_id, add_on='?frame=raw', key=ff_key)

    fill_in(prev_wfr_meta['awsem_app_name'], prev_wfr_meta, prev_file_meta['uuid'])

    # workflow_granite-novoCaller-rck-check
    prev_file_uuid = ''
    for ipf in prev_wfr_meta['input_files']:
        if ipf['workflow_argument_name'] == 'input_vcf':
            prev_file_uuid = ipf['value']
            break
    prev_file_meta = ff_utils.get_metadata(prev_file_uuid, add_on='?frame=object', key=ff_key)
    prev_wfr_id = prev_file_meta['workflow_run_outputs'][0]
    prev_wfr_meta = ff_utils.get_metadata(prev_wfr_id, add_on='?frame=raw', key=ff_key)

    fill_in(prev_wfr_meta['awsem_app_name'], prev_wfr_meta, prev_file_meta['uuid'])

    # workflow_granite-filtering-check
    prev_file_uuid = ''
    for ipf in prev_wfr_meta['input_files']:
        if ipf['workflow_argument_name'] == 'input_vcf':
            prev_file_uuid = ipf['value']
            break
    prev_file_meta = ff_utils.get_metadata(prev_file_uuid, add_on='?frame=object', key=ff_key)
    prev_wfr_id = prev_file_meta['workflow_run_outputs'][0]
    prev_wfr_meta = ff_utils.get_metadata(prev_wfr_id, add_on='?frame=raw', key=ff_key)

    fill_in(prev_wfr_meta['awsem_app_name'], prev_wfr_meta, prev_file_meta['uuid'])

    # workflow_vep-annot-check
    prev_file_uuid = ''
    for ipf in prev_wfr_meta['input_files']:
        if ipf['workflow_argument_name'] == 'input_vcf':
            prev_file_uuid = ipf['value']
            break
    prev_file_meta = ff_utils.get_metadata(prev_file_uuid, add_on='?frame=object', key=ff_key)
    prev_wfr_id = prev_file_meta['workflow_run_outputs'][0]
    prev_wfr_meta = ff_utils.get_metadata(prev_wfr_id, add_on='?frame=raw', key=ff_key)

    fill_in(prev_wfr_meta['awsem_app_name'], prev_wfr_meta, prev_file_meta['uuid'])

    # workflow_peddy & workflow_granite-qcVCF
    for wfri_id in prev_file_meta['workflow_run_inputs']:
        wfri_meta = ff_utils.get_metadata(wfri_id, add_on='?frame=raw', key=ff_key)
        if wfri_meta['awsem_app_name'] == 'workflow_granite-qcVCF' and wfri_meta['run_status'] == 'complete':
            fill_in('workflow_granite-qcVCF', wfri_meta, None)
        elif wfri_meta['awsem_app_name'] == 'workflow_peddy' and wfri_meta['run_status'] == 'complete':
            fill_in('workflow_peddy', wfri_meta, None)

    # workflow_samplegeno
    prev_file_uuid = ''
    for ipf in prev_wfr_meta['input_files']:
        if ipf['workflow_argument_name'] == 'input_vcf':
            prev_file_uuid = ipf['value']
            break
    prev_file_meta = ff_utils.get_metadata(prev_file_uuid, add_on='?frame=object', key=ff_key)
    prev_wfr_id = prev_file_meta['workflow_run_outputs'][0]
    prev_wfr_meta = ff_utils.get_metadata(prev_wfr_id, add_on='?frame=raw', key=ff_key)

    fill_in(prev_wfr_meta['awsem_app_name'], prev_wfr_meta, prev_file_meta['uuid'])

    # workflow_gatk-GenotypeGVCFs-check
    prev_file_uuid = ''
    for ipf in prev_wfr_meta['input_files']:
        if ipf['workflow_argument_name'] == 'input_vcf':
            prev_file_uuid = ipf['value']
            break
    prev_file_meta = ff_utils.get_metadata(prev_file_uuid, add_on='?frame=object', key=ff_key)
    prev_wfr_id = prev_file_meta['workflow_run_outputs'][0]
    prev_wfr_meta = ff_utils.get_metadata(prev_wfr_id, add_on='?frame=raw', key=ff_key)

    fill_in(prev_wfr_meta['awsem_app_name'], prev_wfr_meta, prev_file_meta['uuid'])

    # workflow_gatk-CombineGVCFs
    prev_file_uuid = ''
    for ipf in prev_wfr_meta['input_files']:
        if ipf['workflow_argument_name'] == 'input_gvcf':
            prev_file_uuid = ipf['value']
            break
    prev_file_meta = ff_utils.get_metadata(prev_file_uuid, add_on='?frame=object', key=ff_key)
    prev_wfr_id = prev_file_meta['workflow_run_outputs'][0]
    prev_wfr_meta = ff_utils.get_metadata(prev_wfr_id, add_on='?frame=raw', key=ff_key)

    fill_in(prev_wfr_meta['awsem_app_name'], prev_wfr_meta, prev_file_meta['uuid'])

    # workflow_granite-rckTar
    # first get novocaller
    for wfr in metawfr_meta['workflow_runs']:
        if wfr['name'] == 'workflow_granite-novoCaller-rck-check':
            prev_wfr_meta = ff_utils.get_metadata(wfr['workflow_run'], add_on='?frame=raw', key=ff_key)
            break
    # then get rcktar
    prev_file_uuid = ''
    for ipf in prev_wfr_meta['input_files']:
        if ipf['workflow_argument_name'] == 'trio':
            prev_file_uuid = ipf['value']
            break
    prev_file_meta = ff_utils.get_metadata(prev_file_uuid, add_on='?frame=object', key=ff_key)
    prev_wfr_id = prev_file_meta['workflow_run_outputs'][0]
    prev_wfr_meta = ff_utils.get_metadata(prev_wfr_id, add_on='?frame=raw', key=ff_key)

    fill_in(prev_wfr_meta['awsem_app_name'], prev_wfr_meta, prev_file_meta['uuid'])

    # workflow_granite-mpileupCounts
    prev_file_uuids = []
    for ipf in prev_wfr_meta['input_files']:
        if ipf['workflow_argument_name'] == 'input_rcks':
            prev_file_uuids.append(ipf['value'])
    ## IMPORTANT! V22 rcktar was run with samples in the order of proband-last. We need to switch that
    ## for consistenty with other shard ordering.
    if fastq_order == 1:
        prev_file_uuids.reverse()
        prev_file_uuids_reordered = prev_file_uuids
    elif fastq_order == 2:
        prev_file_uuids_reordered = [prev_file_uuids[-1]]
        prev_file_uuids_reordered.extend(prev_file_uuids[0:-1])

    while(True):
        shard = 0
        for prev_file_uuid in prev_file_uuids_reordered:
            prev_file_meta = ff_utils.get_metadata(prev_file_uuid, add_on='?frame=object', key=ff_key)
            prev_wfr_id = prev_file_meta['workflow_run_outputs'][0]
            prev_wfr_meta = ff_utils.get_metadata(prev_wfr_id, add_on='?frame=raw', key=ff_key)
            fill_in(prev_wfr_meta['awsem_app_name'], prev_wfr_meta, prev_file_meta['uuid'], shard=str(shard))

            # workflow_gatk-ApplyBQSR-check
            prevprev_file_uuid = ''
            for ipf in prev_wfr_meta['input_files']:
                if ipf['workflow_argument_name'] == 'input_bam':
                    prevprev_file_uuid = ipf['value']
                    break
            prev_file_meta = ff_utils.get_metadata(prevprev_file_uuid, add_on='?frame=object', key=ff_key)
            prev_wfr_id = prev_file_meta['workflow_run_outputs'][0]
            prev_wfr_meta = ff_utils.get_metadata(prev_wfr_id, add_on='?frame=raw', key=ff_key)
            fill_in(prev_wfr_meta['awsem_app_name'], prev_wfr_meta, prev_file_meta['uuid'], shard=str(shard))

            # workflow_sort-bam-check
            prevprev_file_uuid = ''
            for ipf in prev_wfr_meta['input_files']:
                if ipf['workflow_argument_name'] == 'input_bam':
                    prevprev_file_uuid = ipf['value']
                    break
            prev_file_meta = ff_utils.get_metadata(prevprev_file_uuid, add_on='?frame=object', key=ff_key)
            prev_wfr_id = prev_file_meta['workflow_run_outputs'][0]
            prev_wfr_meta = ff_utils.get_metadata(prev_wfr_id, add_on='?frame=raw', key=ff_key)
            fill_in(prev_wfr_meta['awsem_app_name'], prev_wfr_meta, prev_file_meta['uuid'], shard=str(shard))

            # workflow_picard-MarkDuplicates-check
            prevprev_file_uuid = ''
            for ipf in prev_wfr_meta['input_files']:
                if ipf['workflow_argument_name'] == 'input_bam':
                    prevprev_file_uuid = ipf['value']
                    break
            prev_file_meta = ff_utils.get_metadata(prevprev_file_uuid, add_on='?frame=object', key=ff_key)
            prev_wfr_id = prev_file_meta['workflow_run_outputs'][0]
            prev_wfr_meta = ff_utils.get_metadata(prev_wfr_id, add_on='?frame=raw', key=ff_key)
            fill_in(prev_wfr_meta['awsem_app_name'], prev_wfr_meta, prev_file_meta['uuid'], shard=str(shard))

            # workflow_merge-bam
            prevprev_file_uuid = ''
            for ipf in prev_wfr_meta['input_files']:
                if ipf['workflow_argument_name'] == 'input_bam':
                    prevprev_file_uuid = ipf['value']
                    break
            prev_file_meta = ff_utils.get_metadata(prevprev_file_uuid, add_on='?frame=object', key=ff_key)
            print(prev_file_meta)
            prev_wfr_id = prev_file_meta['workflow_run_outputs'][0]
            prev_wfr_meta = ff_utils.get_metadata(prev_wfr_id, add_on='?frame=raw', key=ff_key)

            # workflow_add-readgroups
            print(prev_wfr_meta['awsem_app_name'])
            if prev_wfr_meta['awsem_app_name'] == 'workflow_merge-bam-check':

                fill_in(prev_wfr_meta['awsem_app_name'], prev_wfr_meta, prev_file_meta['uuid'], shard=str(shard))

                prevprev_file_uuids = []
                for ipf in prev_wfr_meta['input_files']:
                    if ipf['workflow_argument_name'] == 'input_bams':
                        prevprev_file_uuids.append(ipf['value'])
                shard2 = 0
                #random.shuffle(prevprev_file_uuids)
                for prevprev_file_uuid in prevprev_file_uuids:
                    prev_file_meta = ff_utils.get_metadata(prevprev_file_uuid, add_on='?frame=object', key=ff_key)
                    print(prev_file_meta)
                    prev_wfr_id = prev_file_meta['workflow_run_outputs'][0]
                    prev_wfr_meta = ff_utils.get_metadata(prev_wfr_id, add_on='?frame=raw', key=ff_key)
                    fill_in(prev_wfr_meta['awsem_app_name'], prev_wfr_meta, prev_file_meta['uuid'], shard=str(shard) + ':' + str(shard2))

                    # workflow_bwa-mem_no_unzip-check
                    prevprev_file_uuid = ''
                    for ipf in prev_wfr_meta['input_files']:
                        if ipf['workflow_argument_name'] == 'input_bam':
                            prevprev_file_uuid = ipf['value']
                            break
                    prev_file_meta = ff_utils.get_metadata(prevprev_file_uuid, add_on='?frame=object', key=ff_key)
                    print(prev_file_meta)
                    prev_wfr_id = prev_file_meta['workflow_run_outputs'][0]
                    prev_wfr_meta = ff_utils.get_metadata(prev_wfr_id, add_on='?frame=raw', key=ff_key)
                    fill_in(prev_wfr_meta['awsem_app_name'], prev_wfr_meta, prev_file_meta['uuid'], shard=str(shard) + ':' + str(shard2))

                    shard2 += 1

                shard += 1

            else:  # no merge-bam
                fill_in(prev_wfr_meta['awsem_app_name'], prev_wfr_meta, prev_file_meta['uuid'], shard=str(shard) + ':0')

                # workflow_bwa-mem_no_unzip-check
                prevprev_file_uuid = ''
                for ipf in prev_wfr_meta['input_files']:
                    if ipf['workflow_argument_name'] == 'input_bam':
                        prevprev_file_uuid = ipf['value']
                        break
                prev_file_meta = ff_utils.get_metadata(prevprev_file_uuid, add_on='?frame=object', key=ff_key)
                print(prev_file_meta)
                prev_wfr_id = prev_file_meta['workflow_run_outputs'][0]
                prev_wfr_meta = ff_utils.get_metadata(prev_wfr_id, add_on='?frame=raw', key=ff_key)
                fill_in(prev_wfr_meta['awsem_app_name'], prev_wfr_meta, prev_file_meta['uuid'], shard=str(shard) + ':0')

                shard += 1

        print(json.dumps(metawfr_meta, indent=4))

        # check fastq shard matching
        fastqs_R1 = []
        fastqs_R2 = []
        for wfr in metawfr_meta['workflow_runs']:
            if wfr['name'] == 'workflow_bwa-mem_no_unzip-check':
                wfr_meta = ff_utils.get_metadata(wfr['workflow_run'], add_on='?frame=raw', key=ff_key)
                for ipf in wfr_meta['input_files']:
                    if ipf['workflow_argument_name'] == 'fastq_R1':
                        fastqs_R1.append(ipf['value'])
                    elif ipf['workflow_argument_name'] == 'fastq_R2':
                        fastqs_R2.append(ipf['value'])

        metawfr_input_fastqs_R1 = [ipf['file'] for ipf in metawfr_meta['input'][0]['files']]
        metawfr_input_fastqs_R2 = [ipf['file'] for ipf in metawfr_meta['input'][1]['files']]

        if fastqs_R1 != metawfr_input_fastqs_R1:
            print("Error: fastq ordering does not match.")
            #continue
        if fastqs_R2 != metawfr_input_fastqs_R2:
            print("Error: fastq ordering does not match.")
            #continue
        break

    metawfr_input_fastq_shards = [ipf['dimension'].replace(',', ':') for ipf in metawfr_meta['input'][0]['files']]

    # fastqc
    # r1
    for wfr in metawfr_meta['workflow_runs']:
        if wfr['name'] == 'fastqc-r1':
            for i in range(0, len(fastqs_R1)):
                fastq_meta = ff_utils.get_metadata(fastqs_R1[i], key=ff_key)
                all_runs = []
                for wfri in fastq_meta['workflow_run_inputs']:
                    if wfri['display_title'].startswith('fastqc'):
                        wfri_meta = ff_utils.get_metadata(wfri['uuid'], add_on='?frame=raw', key=ff_key)
                        if wfri_meta['run_status'] == 'complete':
                            all_runs.append(wfri_meta)
                if len(all_runs) == 1:
                    fill_in('fastqc-r1', all_runs[0], None, shard=metawfr_input_fastq_shards[i])
                elif len(all_runs) > 1:
                    wfri_meta = sorted(all_runs, key=lambda x: x['title'])[-1]
                    fill_in('fastqc-r1', wfri_meta, None, shard=metawfr_input_fastq_shards[i])
                else:
                    failed_runs = []
                    for wfri in fastq_meta['workflow_run_inputs']:
                        if wfri['display_title'].startswith('fastqc'):
                            wfri_meta = ff_utils.get_metadata(wfri['uuid'], add_on='?frame=raw', key=ff_key)
                            if wfri_meta['run_status'] == 'error' or wfri_meta['run_status'] == 'started':
                                failed_runs.append(wfri_meta)
                    if len(failed_runs) == 1:
                        fill_in('fastqc-r1', failed_runs[0], None, shard=metawfr_input_fastq_shards[i])
                    elif len(failed_runs) > 1:
                        raise Exception("Error: multiple failed fastq runs! : %s" % str(failed_runs))
    # r2
    for wfr in metawfr_meta['workflow_runs']:
        if wfr['name'] == 'fastqc-r2':
            for i in range(0, len(fastqs_R2)):
                fastq_meta = ff_utils.get_metadata(fastqs_R2[i], key=ff_key)
                all_runs = []
                for wfri in fastq_meta['workflow_run_inputs']:
                    if wfri['display_title'].startswith('fastqc'):
                        wfri_meta = ff_utils.get_metadata(wfri['uuid'], add_on='?frame=raw', key=ff_key)
                        if wfri_meta['run_status'] == 'complete':
                            all_runs.append(wfri_meta)
                if len(all_runs) == 1:
                    fill_in('fastqc-r2', all_runs[0], None, shard=metawfr_input_fastq_shards[i])
                elif len(all_runs) > 1:
                    wfri_meta = sorted(all_runs, key=lambda x: x['title'])[-1]
                    fill_in('fastqc-r2', wfri_meta, None, shard=metawfr_input_fastq_shards[i])
                else:
                    failed_runs = []
                    for wfri in fastq_meta['workflow_run_inputs']:
                        if wfri['display_title'].startswith('fastqc'):
                            wfri_meta = ff_utils.get_metadata(wfri['uuid'], add_on='?frame=raw', key=ff_key)
                            if wfri_meta['run_status'] == 'error' or wfri_meta['run_status'] == 'started':
                                failed_runs.append(wfri_meta)
                    if len(failed_runs) == 1:
                        fill_in('fastqc-r1', failed_runs[0], None, shard=metawfr_input_fastq_shards[i])
                    elif len(failed_runs) > 1:
                        raise Exception("Error: multiple failed fastq runs! : %s" % str(failed_runs))

    # merge-bam
    bams = []
    for wfr in metawfr_meta['workflow_runs']:
        if wfr['name'] == 'workflow_add-readgroups-check':
            bams.append(wfr['output'][0]['file'])
    for wfr in metawfr_meta['workflow_runs']:
        if wfr['name'] == 'workflow_merge-bam-check':
            if 'output' not in wfr:
                wfr['output'] = [{'file': bams[int(wfr['shard'])], 'argument_name': 'merged_bam'}]
                wfr['status'] = 'completed'

    # workflow_gatk-BaseRecalibrator
    bams = []
    for wfr in metawfr_meta['workflow_runs']:
        if wfr['name'] == 'workflow_sort-bam-check':
            bams.append(wfr['output'][0]['file'])
    for wfr in metawfr_meta['workflow_runs']:
        if wfr['name'] == 'workflow_gatk-BaseRecalibrator':
            bam_uuid = bams[int(wfr['shard'])]
            bam_meta = ff_utils.get_metadata(bam_uuid, key=ff_key)
            all_runs = []
            outfile_uuid = ''
            for wfri in bam_meta['workflow_run_inputs']:
                if wfri['display_title'].startswith('workflow_gatk-BaseRecalibrator'):
                    wfri_meta = ff_utils.get_metadata(wfri['uuid'], add_on='?frame=raw', key=ff_key)
                    if wfri_meta['run_status'] == 'complete':
                        all_runs.append(wfri_meta)
                        outfile_uuid = wfri_meta['output_files'][0]['value']  # recalibration report
            if len(all_runs) == 1:
                fill_in('workflow_gatk-BaseRecalibrator', all_runs[0], outfile_uuid, shard=wfr['shard'])
            elif len(all_runs) > 1:
                wfri_meta = sorted(all_runs, key=lambda x: x['title'])[-1]
                fill_in('workflow_gatk-BaseRecalibrator', wfri_meta, None, shard=wfr['shard'])
            else:
                failed_runs = []
                for wfri in bam_meta['workflow_run_inputs']:
                    if wfri['display_title'].startswith('workflow_gatk-BaseRecalibrator'):
                        wfri_meta = ff_utils.get_metadata(wfri['uuid'], add_on='?frame=raw', key=ff_key)
                        if wfri_meta['run_status'] == 'error' or wfri_meta['run_status'] == 'started':
                            failed_runs.append(wfri_meta)
                if len(failed_runs) == 1:
                    fill_in('workflow_gatk-BaseRecalibrator', failed_runs[0], None, shard=wfr['shard'])
                elif len(failed_runs) > 1:
                    wfri_meta = sorted(failed_runs, key=lambda x: x['title'])[-1]
                    fill_in('workflow_gatk-BaseRecalibrator', wfri_meta, None, shard=wfr['shard'])

    # bamqc
    bams = []
    for wfr in metawfr_meta['workflow_runs']:
        if wfr['name'] == 'workflow_gatk-ApplyBQSR-check':
            bams.append(wfr['output'][0]['file'])
    for wfr in metawfr_meta['workflow_runs']:
        if wfr['name'] == 'cgap-bamqc':
            bam_uuid = bams[int(wfr['shard'])]
            bam_meta = ff_utils.get_metadata(bam_uuid, key=ff_key)
            all_runs = []
            for wfri in bam_meta['workflow_run_inputs']:
                if wfri['display_title'].startswith('cgap-bamqc'):
                    wfri_meta = ff_utils.get_metadata(wfri['uuid'], add_on='?frame=raw', key=ff_key)
                    if wfri_meta['run_status'] == 'complete':
                        all_runs.append(wfri_meta)
            if len(all_runs) == 1:
                fill_in('cgap-bamqc', all_runs[0], None, shard=wfr['shard'])
            elif len(all_runs) > 1:
                wfri_meta = sorted(all_runs, key=lambda x: x['title'])[-1]
                fill_in('cgap-bamqc', wfri_meta, None, shard=wfr['shard'])
            else:
                failed_runs = []
                for wfri in bam_meta['workflow_run_inputs']:
                    if wfri['display_title'].startswith('cgap-bamqc'):
                        wfri_meta = ff_utils.get_metadata(wfri['uuid'], add_on='?frame=raw', key=ff_key)
                        if wfri_meta['run_status'] == 'error' or wfri_meta['run_status'] == 'started':
                            failed_runs.append(wfri_meta)
                if len(failed_runs) == 1:
                    fill_in('cgap-bamqc', failed_runs[0], None, shard=wfr['shard'])
                elif len(failed_runs) > 1:
                    wfri_meta = sorted(failed_runs, key=lambda x: x['title'])[-1]
                    fill_in('cgap-bamqc', wfri_meta, None, shard=wfr['shard'])

    # workflow_gatk-HaplotypeCaller
    for wfr in metawfr_meta['workflow_runs']:
        if wfr['name'] == 'workflow_gatk-HaplotypeCaller':
            bam_uuid = bams[int(wfr['shard'])]
            bam_meta = ff_utils.get_metadata(bam_uuid, key=ff_key)
            all_runs = []
            for wfri in bam_meta['workflow_run_inputs']:
                if wfri['display_title'].startswith('workflow_gatk-HaplotypeCaller'):
                    wfri_meta = ff_utils.get_metadata(wfri['uuid'], add_on='?frame=raw', key=ff_key)
                    if wfri_meta['run_status'] == 'complete':
                        all_runs.append(wfri_meta)
                        outfile_uuid = wfri_meta['output_files'][0]['value']
            if len(all_runs) == 1:
                fill_in('workflow_gatk-HaplotypeCaller', all_runs[0], outfile_uuid, shard=wfr['shard'])
            elif len(all_runs) > 1:
                wfri_meta = sorted(all_runs, key=lambda x: x['title'])[-1]
                fill_in('workflow_gatk-HaplotypeCaller', wfri_meta, None, shard=wfr['shard'])
            else:
                failed_runs = []
                for wfri in bam_meta['workflow_run_inputs']:
                    if wfri['display_title'].startswith('workflow_gatk-HaplotypeCaller'):
                        wfri_meta = ff_utils.get_metadata(wfri['uuid'], add_on='?frame=raw', key=ff_key)
                        if wfri_meta['run_status'] == 'error' or wfri_meta['run_status'] == 'started':
                            failed_runs.append(wfri_meta)
                if len(failed_runs) == 1:
                    fill_in('workflow_gatk-HaplotypeCaller', failed_runs[0], None, shard=wfr['shard'])
                elif len(failed_runs) > 1:
                    raise Exception("Error: multiple failed workflow_gatk-HaplotypeCaller runs! : %s" % str(failed_runs))


    final_status = 'completed'
    for wfr in metawfr_meta['workflow_runs']:
        if wfr['status'] == 'failed':
            final_status = 'failed'
            break
        if wfr['status'] == 'pending':
            final_status = 'running'
            break
    if final_status == 'completed':  # temporary fix till schema enum gets fixed
        final_status = 'failed'
    metawfr_meta['final_status'] = final_status

    # patch the metadata!
    if patch:
        ff_utils.patch_metadata(metawfr_meta, metawfr_meta['uuid'], key=ff_key)

    return metawfr_meta
