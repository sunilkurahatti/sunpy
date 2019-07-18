#! /usr/bin/sh
###################################################################################
#
# This script is a wrapper script to start wf_DS_DW_TransactionFact_Post ETL by passing the load_id
# Author		: 
# Date Created	: 
# Modified by		:
# Modified Date	: 
#          
###################################################################################

if [ $# -ne 6 ]
then 
  echo "ERROR: Wrong number of parameters \n"
  exit 1
fi

po_id=$1
folder='$2'
batch=$3
dbconnection_ds=$4
dbconnection_dw=$5
dbconnection_dws=$6

cd $PMTargetFileDir

load_id=`grep LOAD_ID TXN_$po_id.txt | awk -F'=' '{print $2}'`
if [ -z "$load_id" ] 
then
echo "Load id not found \n"
exit 1
fi
echo "Using Load_id :$load_id \n"

echo "Starting the wf_DS_DW_TransactionFact_Post ETL for Load_id:$load_id,Po_id:$po_id\n"
log=`$PMExtProcDir/startetlworkflow.sh workflow=wf_DS_DW_TransactionFacts_Post folder="$2" batch=$3 context=P po_id=$1 dbconnection_ds=$4 dbconnection_dw=$5 dbconnection_dws=$6 p_workflow='wf_DS_DW_Load' load_id=$load_id`
 RETCODE=$?
if [ $RETCODE -ne 0 ]; then
  echo "ERROR: wf_DS_DW_TransactionFacts_Post Load failed. Please check the sess log file \n"
  exit 1
 fi
