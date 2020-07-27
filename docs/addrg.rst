===============
Add Read Groups
===============

This step uses ``AddReadGroups.py`` (https://github.com/dbmi-bgm/cgap-scripts) to add read groups information to the input bam file, according to lanes and flowcells. The script parses the bam file that contains a mix of multiple lanes and flowcells, extracts this information from read headers and adds the proper read group to individual reads, unlike ``picard AddOrReplaceReadGroups`` which assumes a single read group throughout the file. The output bam file is checked for integrity to ensure the file has a header and it is not truncated.

* CWL: workflow_add-readgroups_plus_integrity-check.cwl

