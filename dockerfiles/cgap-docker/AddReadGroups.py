#!/usr/bin/env python3

##############################################
#
#   Add read groups to a BAM file using pysam
#
#   Michele Berselli
#   berselli.michele@gmail.com
#
##############################################

import sys, argparse, os
import copy as cp
import pysam as ps

#Functions
def main(args): # use as args['name']

    #Variables
    directory = args['directory'] if args['directory'] else '.'
    platform = args['platform'] if args['platform'] else 'illumina'
    samplename = args['samplename']
    threads = int(args['threads']) if args['threads'] else 1

    #Data structures
    IDs = set()

    #Reading header and all possible IDs
    samfile = ps.AlignmentFile(args['inputfile'], "rb", threads=threads)

    header = cp.deepcopy(dict(samfile.header))
    header.setdefault('RG', [])

    for read in samfile:
        ID = '_'.join(read.query_name.split(':')[:4])
        IDs.add(ID)
    #end for

    #Updating header with read groups
    {header['RG'].append({'ID': ID, 'PL': platform, 'PU': ID, 'LB': ID, 'SM': samplename}) for ID in IDs}

    #Opening output file
    bamfile = ps.AlignmentFile(directory + '/' + args['inputfile'].split('/')[-1].split('.')[0] + '_rg' + '.bam', 'wb', header=header, threads=threads)

    #Adding read groups to alignments
    samfile = ps.AlignmentFile(args['inputfile'], "rb", threads=threads)
    for read in samfile:
        ID = '_'.join(read.query_name.split(':')[:4])
        read.tags = read.tags + [('RG', ID)]
        bamfile.write(read)
    #end for

    bamfile.close()
# end def main

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Add read groups to a BAM file')

    parser.add_argument('-i','--inputfile', help='input aligned paired-ends BAM file', required=True)
    parser.add_argument('-d','--directory', help='directory to use to write results', required=False)
    parser.add_argument('-t','--threads', help='number of threads to use for compression/decompression', required=False)
    parser.add_argument('-s','--samplename', help='name of the sample', required=True)
    parser.add_argument('-p','--platform', help='name of the sequencing platform', required=False)

    args = vars(parser.parse_args())

    main(args)

# end if
