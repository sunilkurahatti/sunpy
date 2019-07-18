	# Script works only if input file has fields separated by Pipe(|)
#! /bin/sh


filename=$1
cd $2
batch=$3
awk '!/^$/{
a=substr($0,0,index($0,"$")-1)
print substr($0,index($0,"$")+1) > a".dat_""'$batch'"}' $filename 
