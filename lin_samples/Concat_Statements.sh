
#! /usr/bin/sh

if [ $# -ne 1 ]
  then
   echo " Target File Directory Not Specified"
   exit 1
fi

dir=$1

cat $dir/SCHD_FILE_HDR_TRLR.out $dir/SCHD_RECIPIENT.out $dir/SECT_0000_HOLDINGS_STG.out $dir/SCHD_0000_SCHEDULE_STG.out $dir/SECT_0000_VALUE_PERF_STG.out $dir/SECT_0000_MARKET_COMM_STG.out $dir/SECT_0000_CHART_STG.out $dir/SECT_0000_HOLDINGS_GRP_STG.out $dir/SECT_0000_CARP_STG.out $dir/SECT_0000_PERF_DATA_STG.out $dir/SECT_0000_ACT_SUM_STG.out $dir/SECT_0000_INTRO_STG.out $dir/SECT_0000_TRNS_STG.out $dir/SECT_0000_CORP_EVENT_STG.out > $dir/Statements.out

RETCODE=$?
if [ $RETCODE -ne 0 ]
  then
    echo "ERROR:Concat Statements Script Failed"
    exit 1
fi 
