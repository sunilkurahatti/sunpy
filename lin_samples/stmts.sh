# Script works only if input file has fields separated by Pipe(|)
#! /usr/bin/sh

if [ $# -ne 5 ]
  then
   echo " Wrong Sytax .. Usage : $0 Batch_File_Name "
   exit 1
fi

batchfilename=$1
firm_id=`echo $2 | awk '{printf "%07d\n",$1}'`
echo $firm_id

cd `dirname $1`
cat $1 > SI.T.F$firm_id.${3}.$4.SLA$5.INPUT
 RETCODE=$?
         if [ $RETCODE -ne 0 ]
         then
            echo "ERROR:Unable to create 534 Outbound file "
            exit 1
         fi
