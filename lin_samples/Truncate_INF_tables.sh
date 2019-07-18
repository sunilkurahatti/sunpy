#!/bin/sh


user=`whoami`
user_env=`echo $user | sed 's/inf//g'`
##DATE=$(date '+%Y%m%d')
DATETIME=$(date '+%Y%m%d_%H%M%S')

if [ -s $INFA_HOME/etlenvbuild.cfg ]; then

  rep_db_user=`cat $INFA_HOME/etlenvbuild.cfg | egrep "rep_db_user" | awk -F'=' '{print $2}'`
  rep_db_pass=`cat $INFA_HOME/etlenvbuild.cfg | egrep "rep_db_pass" | awk -F'=' '{print $2}'`
  rep_db_conn_str=`cat $INFA_HOME/etlenvbuild.cfg | egrep "rep_db_conn_str" | awk -F'=' '{print $2}'`

else
 echo -e "etlenvbuild.cfg is not present in $INFA_HOME.."
 echo -e "exit 1"
 exit 1
fi

 log_loc=$INFA_HOME/INF_TBL_TRUNCATE
       if [ ! -d ${log_loc} ]; then
        mkdir  ${log_loc}
	chmod 777 ${log_loc}
        else
        echo "Log location = ${log_loc}"
        fi

DB=`$ORACLE_HOME/bin/sqlplus $rep_db_user/$rep_db_pass@$rep_db_conn_str <<EOF
WHENEVER SQLERROR exit 1;
sho user;
set serverout on
spool ${log_loc}/${user}_Truncate_table_$DATETIME.log

TRUNCATE TABLE OPB_SWIDGINST_LOG;

TRUNCATE TABLE  OPB_DTL_SWIDG_LOG;

TRUNCATE TABLE OPB_PERF_COUNT;

TRUNCATE TABLE OPB_SWIDGINST_LOG;

TRUNCATE TABLE OPB_SESS_TASK_LOG;

spool off;
exit
EOF`
   RETCODE=$?
   if [ $RETCODE -gt 0 ]
   then
        echo  "Error in truncation"
     exit 1
   fi
   if [ -s $user_Truncate_table_$DATETIME.log ]; then
     		echo "\n***************************************************************************" "\n"
    		echo "Table truncation is complete\n" 
fi
