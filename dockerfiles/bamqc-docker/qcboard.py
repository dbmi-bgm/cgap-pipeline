#!/usr/bin/env python
# -*- coding: utf-8 -*-
#### qcboard_v1.py
#### made by Daniel Minseok Kwon
#### 2019-09-05 11:03:02
#########################
import sys
import os
import argparse
import json

VERSION = "0.1.2"
VERSION_DATE = "19.09.10"

FIELDLIST_BAMQC = {}
FIELDLIST_BAMQC['PICARD.CMM'] = ['NO_PAIR','NO_PAIR_1','NO_PAIR_2']
FIELDLIST_BAMQC['FASTQC'] = ['GC_PER','DUPLICATION_PER']

# FIELDLIST_BAMQC['FASTQC'].append('Basic_Statistics')
# FIELDLIST_BAMQC['FASTQC'].append('Per_base_sequence_quality')
# FIELDLIST_BAMQC['FASTQC'].append('Per_tile_sequence_quality')
# FIELDLIST_BAMQC['FASTQC'].append('Per_sequence_quality_scores')
# FIELDLIST_BAMQC['FASTQC'].append('Per_base_sequence_content')
# FIELDLIST_BAMQC['FASTQC'].append('Per_sequence_GC_content')
# FIELDLIST_BAMQC['FASTQC'].append('Per_base_N_content')
# FIELDLIST_BAMQC['FASTQC'].append('Sequence_Length_Distribution')
# FIELDLIST_BAMQC['FASTQC'].append('Sequence_Duplication_Levels')
# FIELDLIST_BAMQC['FASTQC'].append('Overrepresented_sequences')
# FIELDLIST_BAMQC['FASTQC'].append('Adapter_Content')
# FIELDLIST_BAMQC['FASTQC'].append('Kmer_Content')

FIELDLIST_BAMQC['SAMTOOLS'] = ['SEQUENCE_LENGTH','NO_MAPPED_READS','NO_UNMAPPED_READS','MAPPED_RATIO','XY_RATIO','EST_GENDER','CHROM_COVERAGE_TAB','COVERAGE_ALL_CHROM','COVERAGE_MAIN_CHROM']
CHROMCOVTAB_HEADERMAP = {'CHROM':'Chromosome','LEN':'Length','MAAPED':'No. Mapped','UNMAPPED':'No. Unmapped','TOTAL':'Total','MAPPED_RATIO':'Mapped Ratio','COVERAGE':'Coverage'}


def run_cmd(scmd, flag=False):
    if flag:
        print (scmd)
    rst = os.popen(scmd)
    rst_cont = rst.read()
    return rst_cont

def fileOpen(path):
    f = open(path, "r")
    return f.read()

def fileSave (path, cont, opt, gzip_flag = "n"):
    if gzip_flag == "gz":
        import gzip
        f = gzip.open(path, opt)
        f.write(cont)
        f.close()
    else:
        f = open (path, opt)
        f.write(cont)
        f.close

def comma(value):
    return "{:,}".format(value)


def gzopen(fname):
    if fname.endswith(".gz") or fname.endswith(".zip"):
        import gzip
        f1 = gzip.GzipFile(fname, "r")
    else:
        f1 = open(fname)
    return f1

def get_options():
    parser = argparse.ArgumentParser(usage='%(prog)s <sub-command> [options]', description='%(prog)s ver' + VERSION + " (" + VERSION_DATE + ")" + ': convert bam to image')
    parser.add_argument('-v', '--version', action='version', version="%(prog)s ver" + VERSION + " (" + VERSION_DATE + ")")

    parser.add_argument('-bam', dest='bam', default='', help='bam file')
    parser.add_argument('-out', dest='out', default='', help='title of output file')
    parser.add_argument('--per_gc', dest='per_gc', default='', help='percentage of GC metric from FASTQC')
    parser.add_argument('--per_dup', dest='per_dup', default='', help='percentage of duplication metric from FASTQC')
    parser.add_argument('-temp', dest='temp', default='qcboard_bamqc.html', help='template html file')
    parser.add_argument('-silence', dest='silence', action="store_true", default=False, help='don\'t print any log.')
    parser.add_argument('-debug', dest='debug', action="store_true", default=False, help='turn on the debugging mode')

    if len(sys.argv) == 1 or (len(sys.argv) == 2 and sys.argv[1][0] != '-'):
        sys.argv.append('-h')
    opt = vars(parser.parse_args())
    return opt


def cli():
    opt = get_options()
    qcb = QCBoard(opt)
    qcb.run()


class QCBoard():
    has_opt_error = False
    out_html = ""
    out_json = ""
    mode = "BAMQC" ## BAMQC or VCFQC

    def __init__(self, opt):
        self.opt = opt
        self.set_outfilenames()
        self.set_infilenames()
        self.qcstat = {}
        self.qcstat['SAMTOOLS'] = {}
        self.qcstat['PICARD.CMM'] = {}
        self.qcstat['FASTQC'] = {}
        self.qcstat['FASTQC']['GC_PER'] = self.opt['per_gc']
        self.qcstat['FASTQC']['DUPLICATION_PER'] = self.opt['per_dup']

    def set_infilenames(self):
        self.infile = {}
        # self.infile['samtools.idxstats'] = self.opt['bam'] + '.idxstats'
        self.infile['samtools.idxstats'] = self.opt['bam'] + '.stat'
        self.infile['picard.cmm.alignment_summary_metrics'] = self.opt['bam'] + '.cmm.alignment_summary_metrics'
        self.infile['fastqc'] = self.opt['bam'][:-4] + '_fastqc.zip'


    def set_outfilenames(self):
        if self.opt['out'].endswith('.html'):
            self.out_html = self.opt['out']
            self.out_json = self.opt['out'][:-5] + '.json'
            self.out_tsv = self.opt['out'][:-5] + '.tsv'
        else:
            self.out_html = self.opt['out'] + '.html'
            self.out_json = self.opt['out'] + '.json'
            self.out_tsv = self.opt['out'] + '.tsv'

    def set_refeq_from_ucsc(self, pos1):
        spos = pos1['g_spos']-self.opt['margin'] - 500
        epos = pos1['g_epos']+self.opt['margin']+1 + 500
        url = "http://genome.ucsc.edu/cgi-bin/das/hg19/dna?segment=chr"+pos1['chrom']+":"+str(spos+1)+","+str(epos+1)
        cont = get_url(url)
        seq = ""
        for line in cont.strip().split('\n'):
            if line[0] != '<':
                seq += line.strip().upper()
        i = 0
        for gpos in range(spos,epos):
            self.refseq[gpos] = seq[i]
            i += 1

    def set_refseq_from_localfasta(self, pos1):
        spos = pos1['g_spos']-self.opt['margin'] - 500
        epos = pos1['g_epos']+self.opt['margin']+1 + 500
        seq = self.get_refseq(self.opt['ref'], pos1['chrom'], spos,epos)
        i = 0
        for gpos in range(spos, epos):
            self.refseq[gpos] = seq[i]
            i += 1

    def get_refseq(self, ref, chrom, spos,epos):
        f = Fasta(ref)
        fastachrommap = {}
        for c1 in list(f.keys()):
            arr = c1.split(' ')
            tchrom = arr[0]
            fastachrommap[tchrom] = c1
        # fasta_chrom = chrom + ' dna:chromosome chromosome:GRCh37:'+chrom+':1:'+str(CHROM_LEN['b37d5'][chrom])+':1'
        refseq = f[fastachrommap[chrom]][spos:epos+1]
        return refseq


    def save_html(self):
        cont = fileOpen(self.opt['temp'])
        cont = cont.replace('##BAMFILE##',self.opt['bam'])

        for k1 in FIELDLIST_BAMQC.keys():
            if len(self.qcstat[k1].keys()) > 0:
                for k2 in FIELDLIST_BAMQC[k1]:
                    if k2 == 'CHROM_COVERAGE_TAB':
                        k2 = 'CHROM_COVERAGE_TAB_HTML'
                    if type(self.qcstat[k1][k2]) == type(1) or type(self.qcstat[k1][k2]) == type(1.1):
                        v1 = comma(self.qcstat[k1][k2])
                    else:
                        v1 = self.qcstat[k1][k2]

                    if k1 == "FASTQC":
                        v1 = v1.replace('PASS','<span class="badge badge-success">PASS</span>')
                        v1 = v1.replace('WARN','<span class="badge badge-warning">WARN</span>')
                        v1 = v1.replace('FAIL','<span class="badge badge-danger">FAIL</span>')

                    cont = cont.replace('##'+k1+'.'+k2+'##', v1)

        fileSave(self.out_html, cont, 'w')
        print ('Saved '+self.out_html)

    def save_json(self):
        d = {}
        for key in self.qcstat:
            if key == 'SAMTOOLS':
                # parsing samtools info
                for k, v in self.qcstat['SAMTOOLS'].items():
                    if k == 'CHROM_COVERAGE_TAB_HTML':
                        pass
                    elif k == 'CHROM_COVERAGE_TAB':
                        d.setdefault('per_chromosome_coverage', [])
                        for chr_str in v.split('|')[1:-1]:
                            chr, len, map, unmap, tot, map_ratio, coverage = chr_str.split(':')
                            d_chr = {'chromosome': chr, 'length': len, 'no_mapped': map,
                                     'no_unmapped': unmap, 'total': tot,
                                     'mapped_ratio': map_ratio, 'coverage': coverage
                                    }
                            d['per_chromosome_coverage'].append(d_chr)
                    else:
                        if k == 'EST_GENDER':
                            k = 'ESTIMATED_GENDER'
                        elif k == 'COVERAGE_ALL_CHROM':
                            k = 'COVERAGE_ALL_CHROMOSOMES'
                        elif k == 'COVERAGE_MAIN_CHROM':
                            k = 'COVERAGE_MAIN_CHROMOSOMES'
                        d.setdefault(k.lower(), v)
            elif key == 'PICARD.CMM':
                for k, v in self.qcstat['PICARD.CMM'].items():
                    d.setdefault(k.lower(), v)

        # writing json
        with open(self.out_json, 'w') as outfile:
            json.dump(d, outfile)
        print ('Saved '+self.out_json)

    def mk_run_script(self):
        pass

    def mk_output(self):
        pass

    def get_samtools_idxstats(self):
        global CHROMCOVTAB_HEADERMAP
        flag = ""
        chromcovtab_html = ""
        chromcovtab = ""

        for line in open(self.infile['samtools.idxstats']):
            arr = line.split('\t')
            arr[-1] = arr[-1].strip()
            if arr[0] == "CHROM":
                flag = "chrcov"

            if flag == "chrcov":
                if arr[0] == "CHROM":
                    chromcovtab_html += '<tr>'
                    for a1 in arr:
                        chromcovtab_html += '<th>'+CHROMCOVTAB_HEADERMAP[a1]+'</th>'
                        if a1 != 'CHROM':
                            chromcovtab += ':'
                        chromcovtab += CHROMCOVTAB_HEADERMAP[a1]
                    chromcovtab_html += '</tr>'
                    chromcovtab += '|'
                else:
                    chromcovtab_html += '<tr><td>'+'</td><td>'.join(arr)+'</td></tr>'
                    chromcovtab += ':'.join(arr) + '|'
                if arr[0] == "MT" or arr[0] == "M":
                    flag = ""

            if flag=="" and "=ALL CHROM=" in line:
                flag = "ALL"
            if flag=="ALL" and "=ONLY MAIN CHROM" in line:
                flag = "MAIN"
            if flag=="MAIN" and "=X,Y CHROM=" in line:
                flag = "XY"

            if flag == "ALL":
                if line[:len("COVERAGE:")] == "COVERAGE:":
                    self.qcstat['SAMTOOLS']['COVERAGE_ALL_CHROM'] = line.replace("COVERAGE:","").strip()
                if line[:len("MAPPED:")] == "MAPPED:":
                    self.qcstat['SAMTOOLS']['NO_MAPPED_READS'] = line.replace("MAPPED:","").strip()
                if line[:len("UNMAPPED:")] == "UNMAPPED:":
                    self.qcstat['SAMTOOLS']['NO_UNMAPPED_READS'] = line.replace("UNMAPPED:","").strip()
                if line[:len("READ_LEN:")] == "READ_LEN:":
                    self.qcstat['SAMTOOLS']['SEQUENCE_LENGTH'] = line.replace("READ_LEN:","").strip()

            if flag == "MAIN":
                if line[:len("COVERAGE:")] == "COVERAGE:":
                    self.qcstat['SAMTOOLS']['COVERAGE_MAIN_CHROM'] = line.replace("COVERAGE:","").strip()
            if flag == "XY":
                if line[:len("X/Y RATIO:")] == "X/Y RATIO:":
                    self.qcstat['SAMTOOLS']['XY_RATIO'] = line.replace("X/Y RATIO:","").strip()
                if line[:len("EXT. GENDER:")] == "EXT. GENDER:":
                    self.qcstat['SAMTOOLS']['EST_GENDER'] = line.replace("EXT. GENDER:","").strip()
            # print (arr)

        self.qcstat['SAMTOOLS']['CHROM_COVERAGE_TAB_HTML'] = chromcovtab_html
        self.qcstat['SAMTOOLS']['CHROM_COVERAGE_TAB'] = chromcovtab
        self.qcstat['SAMTOOLS']['MAPPED_RATIO'] = round(100*int(self.qcstat['SAMTOOLS']['NO_MAPPED_READS'].replace(',','')) / (int(self.qcstat['SAMTOOLS']['NO_MAPPED_READS'].replace(',','')) + int(self.qcstat['SAMTOOLS']['NO_UNMAPPED_READS'].replace(',',''))), 3)


    def get_picard_cmm(self):
        for line in open(self.infile['picard.cmm.alignment_summary_metrics']):
            if line[0] != '#':
                arr = line.split('\t')
                if arr[0] == "FIRST_OF_PAIR":
                    self.qcstat['PICARD.CMM']['NO_PAIR_1'] = int(arr[1])
                if arr[0] == "SECOND_OF_PAIR":
                    self.qcstat['PICARD.CMM']['NO_PAIR_2'] = int(arr[1])
                if arr[0] == "PAIR":
                    self.qcstat['PICARD.CMM']['NO_PAIR'] = int(arr[1])

    def get_fastqc(self):
        # cmd = "unzip -f " + self.infile['fastqc'] + " -d " + '/'.join(self.infile['fastqc'].split('/')[:-1])
        cmd = "unzip " + self.infile['fastqc'] + " -d " + '/'.join(self.infile['fastqc'].split('/')[:-1])
        run_cmd(cmd)
        print (self.infile['fastqc'][:-4] + '/fastqc_data.txt')
        for line in open(self.infile['fastqc'][:-4] + '/fastqc_data.txt'):
            if line[:len('Sequence length')] == 'Sequence length':
                self.qcstat['FASTQC']['SEQUENCE_LENGTH'] = line.split('\t')[1].strip()
            if line[:len('%GC')] == '%GC':
                self.qcstat['FASTQC']['GC_PER'] = line.split('\t')[1].strip()
            if line[:len('#Total Deduplicated Percentage')] == '#Total Deduplicated Percentage':
                self.qcstat['FASTQC']['DUPLICATION_PER'] = str(round(float(line.split('\t')[1].strip()),3))

        print (self.infile['fastqc'][:-4] + '/summary.txt')
        for line in open(self.infile['fastqc'][:-4] + '/summary.txt'):
            line = line.strip()
            arr = line.split('\t')
            self.qcstat['FASTQC'][arr[1].strip().replace(' ','_')] = arr[0].strip()

    def run(self):
        self.get_samtools_idxstats()
        self.get_picard_cmm()
        # self.get_fastqc()
        self.save_html()
        self.save_json()


if __name__ == "__main__":
    print ("#USAGE: python qcboard_v1.py -bam [BAM FILE] -out [OUTPUT TITLE]")
    cli()
