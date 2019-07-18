#!/bin/sh
##########################################################################
# This script is used to purge Real Time ETL session log and 
# retains a day log
# 
# Author         :Ravikumar
# Date Created:  :06-08-2010 
# Date Modified  :
#
# Description    :Script purges the real time ETL session log older than a day 
#
##########################################################################

# Executing configuration files

if [ -s $HOME/etlenvbuild.cfg ] ; then
   . /$HOME/etlenvbuild.cfg
else
   echo "etlenvbuild.cfg file is missing."
   exit 1
fi

if [ -s $HOME/etldeployment.cfg ] ; then
   . /$HOME/etldeployment.cfg
else
   echo "etldeployment.cfg file is missing."
   exit 1
fi

# Validating the user

user=`/usr/ucb/whoami`
user_env=`echo $user|sed 's/inf//g'`
templog=$PMRootDir/SessLogs/pwx_delete_session.log

if [ $user_env != $environment ]; then
   echo "Error:$user does not have permission to perform this task. Use '$environment'inf user to run the script"
   exit 1
fi


database=`echo $oracle_connection_ORACAPT|awk -F: '{print $4}'`

previous_day=`sqlplus -s ORACAPT/ORACAPT@$database << !
SET HEAD OFF;
SELECT TO_CHAR(SYSDATE-1,'DD-Dy-Mon-YYYY') AS PREVIOUS_DAY  FROM DUAL;
EXIT
!`  

RETCODE=$?

if [ $RETCODE -gt 0 ]
then
   echo "Error while getting previous day date from $database..\n"
   echo $previous_day
   exit 1
fi


day=`echo $previous_day|awk -F"-" '{print $2}'`
month=`echo $previous_day|awk -F"-" '{print $3}'`
date=`echo $previous_day|awk -F"-" '{print $1}'`

line_num=`grep -n "SOURCE BASED COMMIT POINT  $day $month $date" $PMRootDir/SessLogs/s_m_QUARTZ_EDB_Transactions_RT.log.bin|tail -1|awk -F":" '{print $1}'`

if [ -n "$line_num" ]; then
 echo "Archiving PWX ETL Session log as of $date $month" 
 perl -i -ne 'print unless 1 .. '$line_num'' $PMRootDir/SessLogs/s_m_QUARTZ_EDB_Transactions_RT.log.bin>>$templog
 if [ -s $templog ]; then
  echo "Error deleting the content of PWX ETL Session log"
  cat $templog
  rm -f $templog
  exit 1
 fi
else
 echo "No contents to archive in PWX ETL Session log as of $date $month"  
fi

echo "Archiving old PWX ETL Session logs"
find $PMRootDir/SessLogs/ ! \( -type f -name "s_m_QUARTZ_EDB_Transactions_RT.log.bin" \) -a \( -type f -name "s_m_QUARTZ_EDB_Transactions_RT.log*" \) -exec rm -f {} \;
RETCODE=$?
if [ $RETCODE -ne 0 ]; then
 echo "Error while archiving old PWX ETL Session logs"
 echo "exit 1"
 exit 1
else
 echo "Successfully archived the old PWX session logs" 
fi 
