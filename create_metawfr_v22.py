import json
import copy
import uuid
from magma_ff.metawfl import MetaWorkflow
from magma_ff.metawflrun import MetaWorkflowRun
from dcicutils import ff_utils

metawf_uuid = '475a0518-9b72-4dc1-b049-070f366ab821'  # v22

# ff_key = ff_utils.get_authentication_with_server(ff_env='fourfront-cgapwolf')
# case_uuid = '1ea344bc-e211-4b11-8bde-7b94dadda7e2'  # NA12879 on cgapwolf

ff_key = ff_utils.get_authentication_with_server(ff_env='fourfront-cgap')
case_uuid = '81278096-7c10-4c5a-8ac3-5e3014e83bbb'  # NA12879 on cgap


def create_metawfr_from_case(metawf_uuid, case_uuid, ff_key, post=False, verbose=False):
    case_meta = ff_utils.get_metadata(case_uuid, add_on='?frame=raw', key=ff_key)
    sp_uuid = case_meta['sample_processing']
    sp_meta = ff_utils.get_metadata(sp_uuid, add_on='?frame=object', key=ff_key)
    pedigree = sp_meta['samples_pedigree']
    pedigree = remove_parents_without_sample(pedigree)  # remove no-sample individuals
    pedigree = sorted(pedigree, key=lambda x: x['relationship'] != 'proband')  # make it proband-first

    # prepare fastq input
    r1_uuids_fam = []
    r2_uuids_fam = []
    i = 0  # first dimension of files
    for sample in pedigree:
        sample_acc = sample['sample_accession']
        sample_meta = ff_utils.get_metadata(sample_acc, add_on='?frame=raw', key=ff_key)
        fastq_uuids = sample_meta['files']
        r1_uuids =[]
        r2_uuids = []
        j = 0  # second dimension of files
        for fastq_uuid in fastq_uuids:
            fastq_meta = ff_utils.get_metadata(fastq_uuid, add_on='?frame=raw', key=ff_key)
            if fastq_meta['paired_end'] == '1':
                dimension = '%d,%d' % (i, j)  # dimension string for files
                r1_uuids.append({'file': fastq_meta['uuid'], 'dimension': dimension})
                r2_uuids.append({'file': fastq_meta['related_files'][0]['file'], 'dimension': dimension})
                j += 1
        r1_uuids_fam.extend(r1_uuids)
        r2_uuids_fam.extend(r2_uuids)
        i += 1

    # sample names
    sample_names = [s['sample_name'] for s in pedigree]
    sample_names_str = json.dumps(sample_names)

    # qc pedigree parameter
    qc_pedigree_str = json.dumps(pedigree_to_qc_pedigree(pedigree))

    # family size
    family_size = len(pedigree)

    # rcktar_content_file_names
    rcktar_content_file_names = [s + '.rck.gz' for s in sample_names]
    rcktar_content_file_names_str = json.dumps(rcktar_content_file_names)

    # create metawfr
    metawf_meta = ff_utils.get_metadata(metawf_uuid, add_on='?frame=raw', key=ff_key)

    input = [{'argument_name': 'fastqs_proband_first_R1', 'argument_type': 'file', 'files': r1_uuids_fam},
             {'argument_name': 'fastqs_proband_first_R2', 'argument_type': 'file', 'files': r2_uuids_fam},
             {'argument_name': 'sample_names_proband_first', 'argument_type': 'parameter', 'value': sample_names_str, 'value_type': 'json'},
             {'argument_name': 'pedigree', 'argument_type': 'parameter', 'value': qc_pedigree_str, 'value_type': 'json'},
             {'argument_name': 'family_size', 'argument_type': 'parameter', 'value': str(family_size), 'value_type': 'integer'},
             {'argument_name': 'rcktar_content_file_names', 'argument_type': 'parameter', 'value': rcktar_content_file_names_str, 'value_type': 'json'}]

    metawfr = {'meta_workflow': metawf_uuid,
               'input': input,
               'title': 'MetaWorkflowRun %s on case %s' % (metawf_meta['title'], case_meta['accession']),
               #'name': 'metawf_%s_on_case_%s' % (metawf_meta['accession'], case_meta['accession']),
               #'name': 'MetaWorkflowRun %s for case %s' % (metawf_meta['title'], case_meta['accession']),
               'project': case_meta['project'],
               'institution': case_meta['institution'],
               'common_fields': {'project': case_meta['project'],
                                 'institution': case_meta['institution']},
               'final_status': 'pending',
               'workflow_runs' : [],
               'uuid': str(uuid.uuid4())}

    mwf = MetaWorkflow(metawf_meta)

    # get the input structure in magma format
    metawfr_mgm = MetaWorkflowRun(metawfr).to_json()
    input_structure = metawfr_mgm['input'][0]['files']

    # create workflow_runs
    mwfr = mwf.write_run(input_structure)
    metawfr['workflow_runs'] = mwfr['workflow_runs']

    # post meta-wfr
    if post:
        res_post = ff_utils.post_metadata(metawfr, 'MetaWorkflowRun', key=ff_key)
        if verbose:
            print(res_post)

    return metawfr


def pedigree_to_qc_pedigree(samples_pedigree):
    """extract pedigree for qc for every family member
    - input samples accession list
    - qc pedigree
    """
    qc_pedigree = []
    # get samples
    for sample in samples_pedigree:
        member_qc_pedigree = {
            'gender': sample.get('sex', ''),
            'individual': sample.get('individual', ''),
            'parents': sample.get('parents', []),
            'sample_name': sample.get('sample_name', '')
            }
        qc_pedigree.append(member_qc_pedigree)
    return qc_pedigree

def remove_parents_without_sample(samples_pedigree):
    individuals = [i['individual'] for i in samples_pedigree]
    for a_member in samples_pedigree:
        parents = a_member['parents']
        new_parents = [i for i in parents if i in individuals]
        a_member['parents'] = new_parents
    return samples_pedigree
