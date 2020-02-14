#!/usr/bin/perl
while(<>){
  chomp;
  if(/(.+name.+)_v11(.+)/) {
    print $1."_v12".$2."\n";
  }
  else {
    print "$_\n";
  }
}
