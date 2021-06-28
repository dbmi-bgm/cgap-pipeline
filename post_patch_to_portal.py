import os
import json
from dcicutils import ff_utils
import argparse


def main(ff_env='fourfront-cgapwolf', skip_software=False, skip_file_format=False,
         skip_workflow=False, skip_metaworkflow=False, del_prev_version=False):
    """post / patch contents from portal_objects to the portal"""
    keycgap = ff_utils.get_authentication_with_server(ff_env=ff_env)

    # Software
    if not skip_software:
        print("Processing software...")
        with open('portal_objects/software.json') as f:
            d = json.load(f)

        for dd in d:
            print("  processing uuid %s" % dd['uuid'])
            try:
                ff_utils.post_metadata(dd, 'Software', key=keycgap)
            except:
                ff_utils.patch_metadata(dd, dd['uuid'], key=keycgap)

    # File formats
    if not skip_file_format:
        print("Processing file format...")
        with open('portal_objects/file_format.json') as f:
            d = json.load(f)

        for dd in d:
            print("  processing uuid %s" % dd['uuid'])
            try:
                ff_utils.post_metadata(dd, 'FileFormat', key=keycgap)
            except:
                ff_utils.patch_metadata(dd, dd['uuid'], key=keycgap)

    # Metaworkflows
    if not skip_metaworkflow:
        print("Processing metaworkflow...")
        wf_dir = "portal_objects/metaworkflows"
        files = os.listdir(wf_dir)

        for fn in files:
            if fn.endswith('.json'):
                print("  processing file %s" % fn)
                with open(os.path.join(wf_dir, fn), 'r') as f:
                    d = json.load(f)
                try:
                    ff_utils.post_metadata(d, 'MetaWorkflow', key=keycgap)
                except:
                    ff_utils.patch_metadata(d, d['uuid'], key=keycgap)

    # Workflows
    if not skip_workflow:
        print("Processing workflow...")
        wf_dir = "portal_objects/workflows"
        files = os.listdir(wf_dir)

        for fn in files:
            if fn.endswith('.json'):
                print("  processing file %s" % fn)
                with open(os.path.join(wf_dir, fn), 'r') as f:
                    d = json.load(f)

                if del_prev_version:
                    # Clean previous version and aliases if present
                    if d.get('previous_version'):
                        del d['previous_version']
                    if d.get('aliases'):
                        d['aliases'] = [d['aliases'][0]]

                # Patch
                try:
                    ff_utils.post_metadata(d, 'Workflow', key=keycgap)
                except:
                    ff_utils.patch_metadata(d, d['uuid'], key=keycgap)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--ff-env', default='fourfront-cgapwolf')
    parser.add_argument('--skip-software', action='store_true')
    parser.add_argument('--skip-file-format', action='store_true')
    parser.add_argument('--skip-workflow', action='store_true')
    parser.add_argument('--skip-metaworkflow', action='store_true')
    parser.add_argument('--del-prev-version', action='store_true')
    args = parser.parse_args()
    main(ff_env=args.ff_env, skip_software=args.skip_software,
         skip_file_format=args.skip_file_format, skip_workflow=args.skip_workflow,
         skip_metaworkflow=args.skip_metaworkflow, del_prev_version=args.del_prev_version)
