import subprocess
import hashlib
import argparse
import os


registry_url_base = 'https://www.ebi.ac.uk/ena/cram/md5'


def add_to_fasta(line, fout):
    """Given a line in the md5 list returned from cramtools getref,
    download the corresponding sequence from the reference sequence registry,
    and add the content to the output file object.
    
    The line looks like below:
    >chr1 4a972df76bd3ee2857b87bd5be5e4a0a
    """
    (chrom, md5) = line.split(' ')
    md5 = md5.rstrip()
    url = "%s/%s" % (registry_url_base, md5)
    
    # download from registry
    try:
        subprocess.call(['wget', url])
    except Exception as e:
        raise Exception(e)

    # check md5 of the downloaded file
    with open(md5, 'r') as f:
        content = f.read().rstrip()
    content_md5 = hashlib.md5(content.encode('utf-8')).hexdigest()
    print("md5 of the content for %s = %s" % (md5, content_md5))
    if md5 != content_md5:
        os.remove(md5)
        raise Exception("md5 mismatch: %s vs %s" % (md5, content_md5))

    # write the header and content to output fasta
    fout.write(chrom + '\n')
    fout.write(content + '\n')
    
    # remove the downloaded file
    os.remove(md5)


def md5list_to_fasta(md5list, fasta):
    """Given the md5 list (file) returned from cramtools getref,
    download the corresponding sequences from the reference sequence registry,
    and write them to the output file.
    
    md5list: input reference md5 list file
    fasta: output reference genome fasta file (not gzipped)
    """
    with open(fasta, 'w') as fout:
        with open(md5list, 'r') as f:
            for line in f:
                add_to_fasta(line.rstrip(), fout)


if __name__ == '__main__':

    # parse args
    parser = argparse.ArgumentParser(description = 'Create a reference fasta file from ENA md5 list' +
                                                   'retrieved from cramtools getref')
    parser.add_argument('-i','--input_md5list', help = "input pairs file")
    parser.add_argument('-o','--output-fasta', help = "input chromsize file")
    args = parser.parse_args()
    
    # run
    md5list_to_fasta(args.input_md5list, args.output_fasta)
