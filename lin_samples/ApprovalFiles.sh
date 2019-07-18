#!/bin/bash

if [ $# -ne 7 ]
then
    echo " Wrong Sytax ..  "
    echo "The following parameters were received-"
        echo "Header File Name: \t${1:-EMPTY}"
        echo "Detail File Name: \t${2:-EMPTY}"
        echo "Trailer File Name: \t${3:-EMPTY}"
        echo "Firm ID: \t${4:-EMPTY}"
        echo "Package Type: \t${4:-EMPTY}"
        echo "SLA: \t${4:-EMPTY}"
        echo "\nUsage:"
        echo "Merge_split_batch.sh <Header_File_name> <Detail_File_name> <Trailer_File_name> <Firm_ID> <Package_Type> <SLA>"

fi
cd `dirname $1`
hdr_batchfilename=$1
dtl_batchfilename=$2
trl_batchfilename=$3
firm_id=$4
package_type=$5
sla=$6
batch_id=$7
        
       # batch_id=`echo "$1"|cut -f2 -d"|"|sed 's/ //g'`
       	 firm_id=`echo $4 | awk '{printf "%07d\n",$1}'`


        if test -s $hdr_batchfilename
        then  
        sed 's/|//g' $1|awk '{printf "%-95s\n",$0}'>SI.T.F${firm_id}.${batch_id}.${package_type}.SLA${sla}.INPUT
        else 
         echo " Header file not found ..  : $1 $2 $3 $4 $5 $6 $7"
         exit 1
        fi
         
        if test -s $dtl_batchfilename
           then
              batch=`echo "D|$batch_id"`
              cat $dtl_batchfilename | grep "^`echo $batch`"|sed 's/|//g'>>SI.T.F${firm_id}.${batch_id}.${package_type}.SLA${sla}.INPUT
        else
         echo " Detail file not found ..  : $1 $2 $3 $4 $5 $6 $7 "
         exit 1        

        fi
        if test -s $trl_batchfilename
           then
              batch=`echo "T|$batch_id"`
              cat $trl_batchfilename | grep "^`echo $batch`"|sed 's/|//g'>>SI.T.F${firm_id}.${batch_id}.${package_type}.SLA${sla}.INPUT
        else
         echo " Trailer file not found ..  : $1 $2 $3 $4 $5 $6 $7"
         exit 1       
        fi

cd `dirname $1`
rm -f $1
rm -f $2
rm -f $3
