#!/bin/bash

file=$1

if [[ $file =~ \.gz$ ]]
then
  MD_OUT=($(md5sum $file))
  CONTENT_MD_OUT=($(gunzip -c $file | md5sum))
else
  MD_OUT=($(md5sum $file))
  CONTENT_MD_OUT=$MD_OUT
fi

MD=${MD_OUT[0]}
CONTENT_MD=${CONTENT_MD_OUT[0]}
echo "$MD" >> report
echo "$CONTENT_MD" >> report
