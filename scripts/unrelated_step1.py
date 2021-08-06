
import json
from dcicutils import ff_utils
import copy
from magma import metawfl as wfl
import uuid


def create_metawfr(input_json, run_json, idx):
  name = 'NAME'
  for d in input_json[idx]:
    if d['argument_name'] == 'sample_names':
      name = json.loads(d['value'])[0]
      break

  run_json_ = copy.deepcopy(run_json)
  run_json_['input'] = input_json[idx]
  run_json_['uuid'] = str(uuid.uuid4())
  run_json_['project'] = '12a92962-8265-4fc0-b2f8-cf14f05db58b'
  run_json_['institution'] = '828cd4fe-ebb0-4b36-a94a-d2e3a36cc989'
  run_json_['title'] = 'MetaWorkflowRun for unrelated UGRP %s' % (name)
  run_json_['final_status'] = 'pending'

  return run_json_

def get_input(input, idx):
  inpt = copy.deepcopy(input)
  inpt_ = []
  for d in inpt:
    d_ = {}
    for k, v in d.items():
      if k == 'files':
        v_ = [v[idx]]
        v_[0]['dimension'] = '0'
      elif k == 'value':
        v_json = json.loads(v)
        v_ = "[\"{0}\"]".format(v_json[idx])
      else: v_ = v
      d_.setdefault(k, v_)
    inpt_.append(d_)
  return inpt_


ff_key = ff_utils.get_authentication_with_server(ff_env='fourfront-cgapwolf')

metawfr_20 = ff_utils.get_metadata('c10974fc-b383-4165-8122-7d282a7f29f1', add_on='?frame=raw&datastore=database', key=ff_key)
metawf = ff_utils.get_metadata('ecc83f50-7301-4c2c-8367-cbec402bbde1', add_on='?frame=raw&datastore=database', key=ff_key)
wfl_obj = wfl.MetaWorkflow(metawf)

input_json = []
for i in range(20):
  input_json.append(get_input(metawfr_20['input'], i))

input = ['file']
end_steps = ['workflow_gatk-ApplyBQSR-check', 'cgap-bamqc-5', 'cgap-bamqc-4', 'cgap-bamqc-3', 'cgap-bamqc-2', 'cgap-bamqc-1', 'cgap-bamqc']

run_json = wfl_obj.write_run(input, end_steps)

uuid_list = []
for i in range(20):
  to_post = create_metawfr(input_json, run_json, i)
  print('Posting' + to_post['uuid'])
  uuid_list.append(to_post['uuid'])
  ff_utils.post_metadata(to_post, 'MetaWorkflowRun', key=ff_key)
