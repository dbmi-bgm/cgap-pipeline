#!/usr/bin/env python
# -*- coding: utf-8 -*-
#### bamstat.py
#### made by Daniel Minseok Kwon
#### 2017-10-29 16:07:31
#########################
import sys
import os

samtools = "samtools"

EXOM_SEQ_COVERED_REGION_NimbleGen_SeqCap=64190747
EXOM_SEQ_COVERED_REGION = EXOM_SEQ_COVERED_REGION_NimbleGen_SeqCap


def comma(value):
    return "{:,}".format(value)

def run_cmd(scmd, flag=False):
    if flag:
        print (scmd)
    rst = os.popen(scmd)
    rst_cont = rst.read()
    return rst_cont


def bamstat(bam):
    read_len = 0
    cmd_cont = run_cmd(samtools+ " view "+bam+" | head -1000")
    i = 0
    for line in cmd_cont.strip().split('\n'):
        if len(line) > 0 and line[0] != '@':
            arr= line.split('\t')
            if len(arr[9]) > read_len:
                read_len = len(arr[9])
            i += 1
            if i > 10:
                break

    cont = []
    cont.append("CHROM")
    cont.append("LEN")
    cont.append("MAAPED")
    cont.append("UNMAPPED")
    cont.append("TOTAL")
    cont.append("MAPPED_RATIO")
    cont.append("COVERAGE")
    print('\t'.join(cont))

    total_unmapped = 0
    total_mapped = 0
    total_len = 0
    main_mapped = 0
    main_unmapped = 0
    main_len = 0
    cmd = samtools + " idxstats " + bam
    cmd_cont = run_cmd(cmd)
    x_chrom_total_reads = 0
    y_chrom_total_reads = 0

    for line in cmd_cont.strip().split('\n'):
        arr = line.split('\t')
        #print(arr)
        mapped = int(arr[2])
        unmapped = int(arr[3])
        total_line = mapped+unmapped 
        total_mapped += mapped
        if arr[0][:3] == "chr":
            chrom = arr[0][3:]
        else:
            chrom = arr[0]

        if chrom == "*":
            total_unmapped += unmapped
        chrom_len = int(arr[1])
        total_len += chrom_len

        if chrom_len == 0:
            cov = 0
        else:
            cov = (read_len * mapped) / chrom_len

        if len(chrom) <= 2:
            main_mapped += mapped
            if chrom == "*":
                main_unmapped += unmapped
            main_len += chrom_len

        cont = []
        cont.append(chrom)
        cont.append(comma(chrom_len))
        cont.append(comma(mapped))
        cont.append(comma(unmapped))
        cont.append(comma(total_line))
        if total_line > 0:
            cont.append(str(round(100*mapped/total_line,2))+'%')
        else:
            cont.append("0%")
        cont.append(str(round(cov,1)))

        if chrom == "X":
            x_chrom_total_reads = total_line
        if chrom == "Y":
            y_chrom_total_reads = total_line

        print('\t'.join(cont))

    total_reads = total_unmapped + total_mapped
    cov = (read_len * total_mapped) / total_len
    exomcov = (read_len * total_mapped) / EXOM_SEQ_COVERED_REGION
    print ("================ALL CHROM=================")
    print("READ_LEN:",read_len)
    print ("MAPPED:",comma(total_mapped))
    print ("UNMAPPED:",comma(total_unmapped))
    print ("TOTAL READS:",comma(total_reads))
    print ("TOTAL LENGTH:",comma(total_len))
    print ("COVERAGE:",round(cov,1))
    print ("EXOM COVERAGE:",round(exomcov,1))

    main_reads = main_mapped + main_unmapped
    if main_len == 0:
        main_cov = 0.0
    else:
        main_cov = (read_len * main_mapped) / main_len
    main_exomcov = (read_len * main_mapped) / EXOM_SEQ_COVERED_REGION
    print ("=======ONLY MAIN CHROM (1~22,X,Y,MT)=======")
    print ("MAPPED:",comma(main_mapped), " (",round(100*main_mapped/total_mapped,1),"% )")
    #if total_unmapped == 0:
    #   print ("UNMAPPED:",comma(main_unmapped), " (",round(100*0,1),"% )")
    #else:
    #   print ("UNMAPPED:",comma(main_unmapped), " (",round(100*main_unmapped/total_unmapped,1),"% )")
    #print ("TOTAL READS:",comma(main_reads) , " (",round(100*main_reads/total_reads,1),"% )")
    print ("TOTAL LENGTH:",comma(main_len) , " (",round(100*main_len/total_len,1),"% )")
    print ("COVERAGE:",round(main_cov,1))
    print ("EXOM COVERAGE:",round(main_exomcov,1))
    print ("=======X,Y CHROM=======")
    print ("chrX READS:",comma(x_chrom_total_reads) + ' (' + str(round(100*x_chrom_total_reads/total_reads,3)) + '%)')
    print ("chrY READS:",comma(y_chrom_total_reads) + ' (' + str(round(100*y_chrom_total_reads/total_reads,3)) + '%)')
    if y_chrom_total_reads <= 0:
        print ("X/Y RATIO: 0")
        print ("EXT. GENDER: NA")
    else:
        print ("X/Y RATIO:",round(x_chrom_total_reads/y_chrom_total_reads,2))
        
        if x_chrom_total_reads/y_chrom_total_reads<200:
            gender = "Male"
        else:
            gender = "Female"
        print ("EXT. GENDER:",gender)

if __name__ == "__main__":
    bam = sys.argv[1]
    bamstat(bam)
