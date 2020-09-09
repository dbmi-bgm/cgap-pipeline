===================
BAM Quality Control
===================

Overview
++++++++

To evaluate the quality of a BAM file, different metrics are calculated using a custom script ``bamqc.py``.

The metrics currently available are:

  - mapping stats
    - total reads
    - reads w/ both mates mapped
    - reads w/ one mate mapped
    - reads w/ neither mate mapped
  - read length
  - coverage


Definitions
+++++++++++

Mapping stats
-------------

The number of reads (not alignments) are counted as number unique read pairs, i.e. if a read pair is mapped to multiple locations, it is counted once.


Coverage
________

Coverage (=Depth of Coverage) is calculated as below:

::

    { (number of reads w/ both mates mapped) * (read length) * 2 + (number of reads w/ one mate mapped) * (read length) } / (effective genome size)


where effective genome size is the number of non-N bases in the genome.



