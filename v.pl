#!/usr/bin/perl

# apply this script to individual files in portal/workflow/ to update versions

$old='v24';
$new='v25';

while(<>){
  chomp;

  # alias
  if(/(.+aliases.+)\[(.+)_$old\",(.*)/) {
    print $1."[".$2."_$new\", ".$2."_$old\",".$3."\n";
  }
  elsif(/(.+aliases.+)\[(.+)_$old\"\](.*)/) {
    print $1."[".$2."_$new\", ".$2."_$old\"]".$3."\n";
  }
  # app version
  elsif(/(.+app_version.+)$old(.+)/) {
    print $1."$new".$2."\n";
  }
  # cwl url
  elsif(/(.+)\/$old\/(.+)/) {
    print $1."/$new/".$2."\n";
  }
  # docker image name
  elsif(/(.+):$old(.+)/) {
    print $1.":$new".$2."\n";
  }
  # workflow name
  elsif(/(.+name.+)_$old(.+)/) {
    print $1."_$new".$2."\n";
  }
  else {
    print "$_\n";
  }
}
