#################################################################
#   Warning
################################################################

# This test will fail without pytest and pytest-shell

#################################################################
#   Libraries
#################################################################
import sys, os, filecmp
import pytest # requires pytest and pytest-shell
from subprocess import Popen

#################################################################
#   Table of Test Variants (Comma delimited)
#################################################################

#,ID Columns,,,
#Base order in test file,Sample VCF,dbSNP VCF,Expected output,Notes
#2,.,no variant,.,
#1,.,rsID,rsID,
#7,.,3 variants,rsID;rsID;rsID,
#8,rsID,no variant,.,*multiallelic split example where wrong rsID is retained in one
#6,rsID,2 variants,rsID;rsID,
#10,rsID;rsID,no variant,.,
#9,rsID;rsID,4 variants,rsID;rsID;rsID;rsID,
#5,otherID,no variant,otherID,
#3,otherID,1 variant,otherID;rsID,
#4,rsID;otherID;otherID,1 variant,otherID;otherID;rsID,*input rsID is rsID123test and output is real (from dbSNP) - shows the drop from sample and the pickup from dbSNP

#################################################################
#   Tests
#################################################################

def test_full_process(bash):
    # Variables and Run
    cwd = os.getcwd()
    bash.run_script(cwd+'/dockerfiles/cgap-docker/parallel_dbSNP_ID_fixer.sh',['files/dbSNPfix_dbSNP151_data_test.vcf.gz','files/dbSNPfix_sample_data_test.vcf.gz','files/dbSNPfix_region_file.txt','2'])
    # Test
    a = os.popen('bgzip -c -d fixed_dbSNPfix_sample_data_test.vcf.gz')
    b = os.popen('bgzip -c -d files/dbSNPfix_ref_fixed_sample_data_test.vcf.gz')
    #b = os.popen('bgzip -c -d ref_wrong_fixed_fake_input_data_test.vcf.gz')
    assert [row for row in a.read()] == [row for row in b.read()]
    # Clean
    os.remove('fixed_dbSNPfix_sample_data_test.vcf.gz')
    os.remove('fixed_dbSNPfix_sample_data_test.vcf.gz.tbi')
