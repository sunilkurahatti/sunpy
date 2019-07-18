# Script works only if input file has fields separated by Pipe(|)
#! /usr/bin/sh


if [ $# -ne 3 ]
  then
   echo " Wrong Sytax .. Usage : $0 GWP_PBGB_Out_Accounts_Dtl PBGB_OUT_Acts_sort_space.err "
   exit 1
fi

batchfilename=$1

cd `dirname $1`
cat $batchfilename | sort -t"|" -k1 -k7 -k16 -k25 2> $2  > $3

if test -s $2
then
    echo "Sorting Space Error"
    exit 1
fi
