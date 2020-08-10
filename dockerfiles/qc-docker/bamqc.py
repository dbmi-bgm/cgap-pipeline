import argparse
import subprocess
import json


def main():
    parser = argparse.ArgumentParser(description='bam qc')
    parser.add_argument('input_bam', help='input bam file')
    parser.add_argument('-o', '--outprefix',
                        default='out',
                        help='output prefix for collated bam and stats')
    parser.add_argument('-s', '--sample',
                        help='sample name')
    parser.add_argument('-p', '--nthreads', type=int,
                        default=1,
                        help='number of processes to use')
    parser.add_argument('-t', '--tmpprefix',
                        default='tmp-',
                        help='prefix for tmp files, default tmp-')
    parser.add_argument('-g', '--eff-genome-size', type=int,
                        default=2913022398,  # GRCh38 number of non-N bases
                        help='effective genome size (integer)')
    parser.add_argument('--skip-collate',
                        action='store_true',
                        help='the input file is already collated, skip collate')

    args = parser.parse_args()

    # output dictionary
    output = dict()
    output['mapping stats'] = dict()

    # first collate bam by reads
    if args.skip_collate:
        collated_bam = args.input_bam
    else:
        collated_bam = args.outprefix + '.collated.bam'
        p = subprocess.Popen(['samtools', 'collate', '-@' + str(args.nthreads), '-o',
                              collated_bam, args.input_bam, args.tmpprefix],
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = p.communicate()
        if p.returncode != 0:
            raise Exception(stderr)

    # calculate mapping stats
    command_total_reads = 'samtools view -@%d %s | cut -f1 | uniq | wc -l' % (args.nthreads, collated_bam)
    command_both_mapped = 'samtools view -@%d -F12 %s | cut -f1 | uniq | wc -l' % (args.nthreads, collated_bam)
    command_mapped_singletons = 'samtools view -@%d -F 0x4 -f 0x8 %s | cut -f1 | uniq | wc -l' % (args.nthreads, collated_bam)
    command_both_unmapped = 'samtools view -@%d -f12 %s | cut -f1 | uniq | wc -l' % (args.nthreads, collated_bam)

    stats = output['mapping stats']
    stats['total reads'] = int(subprocess.check_output(command_total_reads, shell=True).decode().rstrip('\n'))
    stats['both mates mapped'] = int(subprocess.check_output(command_both_mapped, shell=True).decode().rstrip('\n'))
    stats['one mate mapped'] = int(subprocess.check_output(command_mapped_singletons, shell=True).decode().rstrip('\n'))
    stats['neither mate mapped'] = int(subprocess.check_output(command_both_unmapped, shell=True).decode().rstrip('\n'))

    if stats['both mates mapped'] + stats['one mate mapped'] + stats['neither mate mapped'] != stats['total reads']:
        raise Exception("stats do not match - %s" % str(output))

    # read length (assumes constant across file, just use the first read)
    command_read_length = "samtools view %s |head -1 | cut -f10 | tr -d '\n'  | wc -m" % collated_bam
    stats['read length'] = int(subprocess.check_output(command_read_length, shell=True).decode().rstrip('\n'))

    # depth of coverage
    total_read_coverage = (stats['both mates mapped'] * 2 + stats['one mate mapped']) * stats['read length']
    output['coverage'] = str(round(total_read_coverage / args.eff_genome_size, 1)) + 'X'

    # sample name
    output['sample'] = args.sample

    # print output
    with open(args.outprefix + '.stats', 'w') as f:
        json.dump(output, f, indent=4)
        f.write('\n')

if __name__ == '__main__':
    main()
