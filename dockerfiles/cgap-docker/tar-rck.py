#!/usr/bin/env python

#################################################################
#
#   Create tar archive and associate index file to be used
#       by novoCaller from bgzip and tabix indexed rck files
#
#################################################################
import sys, os
import argparse
import tarfile


# Command line arguments
parser = argparse.ArgumentParser(description='Create tar archive and associate index file to be used by novoCaller (from rck gz)')
parser.add_argument('--files', help='list of files to be archived (e.g. SampleID_1.rck.gz SampleID_2.rck.gz ...)', nargs='+', required=True)

args = vars(parser.parse_args())

# Create index file
with open('files.rck.tar.index', 'w') as fo:
    for file in args['files']:
        fo.write(file.split('.')[0] + '\t' + file + '\n')
    # end for
#end with

# Create tar file
tar_file = tarfile.open("files.rck.tar", 'w')

for file in args['files']:
    tar_file.add(file)
    tar_file.add(file + '.tbi')
#end for

tar_file.close()
