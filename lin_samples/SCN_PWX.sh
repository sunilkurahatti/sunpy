###################################################################################
#
# This script can be used to get the archieved log details for the environment
# Author:       LM	
# Date Created: 06/29/09
#         
###################################################################################



if [ -z "$INFA_HOME" ];then 
   echo "\$INFA_HOME is not defined.....\n" 
   echo "exit 1"
   exit 1

 fi

if [ -s $INFA_HOME/etlenvbuild.cfg ] || [ -s $INFA_HOME/etl_deployment.cfg ]; then
   . $INFA_HOME/etlenvbuild.cfg
   . $INFA_HOME/etldeployment.cfg
else
   echo "etlenvbuild.cfg or etldeployment.cfg is not present in $INFA_HOME..."
   echo "exit 1"
   exit 1
   
 fi
 
 
result1=/tmp/$$result1_$environment.txt
archieved_log_details1=/tmp/$$union_archieved_log_details1.sql
 
  if  [ `ps -ef | grep dtllst | grep "$environment"inf | wc -l` -le 2 ]
  then
  
  echo "wf_QUARTZ_EDB_Transactions_RT PWX Workflow is down \n"
  
  else
  
  echo "\nThe following statistics is for running PWX workflow in $environment as of :`date`\n"
  
  PROC_SCN=`grep 'Processing SCN' $INFA_HOME/powerex/logs/detail.log | tail -1 | awk '{print $9}' | sed 's/<//g' | sed 's/>.//g'`
  
            if [ $PROC_SCN ]
	     then
              cat $INFA_HOME/server/infa_shared/ExtProc/get_archieved_log_details.sql|sed "-e s/\$WORKFLOW/wf_QUARTZ_EDB_Transactions_RT/g"|sed "-e s/\$PROCESSING_SCN/$PROC_SCN/g">>$archieved_log_details1
            else
              echo "Error, Processing SCN is not found for wf_QUARTZ_EDB_Transactions_RT ..."
	      echo "exit 1"
             exit 1
             fi
  
     username=`echo $oracle_connection_ORACAPT|awk -F: '{print $2}'`
     password=`echo $oracle_connection_ORACAPT|awk -F: '{print $3}'`
     database=`echo $oracle_connection_ORACAPT|awk -F: '{print $4}'`
  
              sqllog=`sqlplus $username/$password@$database <<EOA
              WHENEVER SQLERROR EXIT SQL.SQLCODE
              @$archieved_log_details1 $result1
              EOA`
              RETCODE=$?
              if [ $RETCODE -gt 0 ]
              then
                 echo "Error querying database for archieved logs.....\n"
     	           echo $sqllog
   		       echo "exit 1"
                     rm -f $archieved_log_details1
  	       exit 1
              fi
  
  
  if [ -s $result1 ]
  then
  echo "WORKFLOW_NAME                       : PROCESSING_SCN  : ARCHIEVELOG_NAME                   :  FIRST_TIME                :  COMPLETION_TIME\n"
  cat $result1 
  echo "\n"
  fi
  rm -f $result1
  rm -f $archieved_log_details1
  
  fi
   
   
   