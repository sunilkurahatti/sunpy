#! /bin/sh
###################################################################################
#
# This script is used to delete session logs, workflow logs based on retention count.
# Author	: Lijju Mathew	
# Date Created	: 02/02/10
# Modified by	:
# Modified Date	: 
#          
###################################################################################


### procedure to delete the logs ###

delete_log()
{
log_name=$1
count=$2	
path_to_del=$HOME/server/infa_shared/$log_name/
cd  $HOME/server/infa_shared/$log_name/

### Listing Session/Workflow logs or Cache files ###

for i in `find $path_to_del -maxdepth 1 -type f -mtime +$2 -print`;
do
 echo -e "Deleting these files $i";rm -f $i;

 ### Deleting old Session/Workflow log files ###
 
RETCODE=$?

 if [ $RETCODE -ne 0 ]; then
  echo "ERROR: Error while deleting $log_name $i"
  exit 1
 fi

done
}

### Checking the Configuration File ###

if [ -s $HOME/etlenvbuild.cfg ] ; then
   . /$HOME/etlenvbuild.cfg
else
   echo "Configuration file is missing."
   exit 1
fi


### Retention count ###

#if [ $# -eq 1 ]
#then 
   #retention_count=$1
#else
   #retention_count=14
#fi

### Checking the user running the script ###

user=`/usr/bin/whoami`
user_env=`echo $user | sed 's/inf//g'`
if [[ $user_env != $environment ]]; then
   echo "Error:$user does not have permission to perform this task. Use '$environment'inf user to run the script"
   exit 1
fi

### setting up the retention_count to handle lower environment ####

if [[ $user =~ ^p[g0-9][0-9] ]]
then
        retention_count=30
else
        retention_count=14
fi



### To clean up Cache Logs ###
echo "Deleting the old Cache files \n"
delete_log Cache 2 


### To clean up Session Logs ###

echo "Deleting the session logs \n"
delete_log SessLogs $retention_count

### To clean up Workflow Logs ###
echo "Deleting the workflow logs \n"
delete_log WorkflowLogs $retention_count

### To clean up Temp Logs ###
delete_log Temp $retention_count

### To clean up Detail Logs ###
if [ -s $HOME/powerex/logs/detail.log ]; then
 cd $HOME/powerex/logs
 ### Backup detail log ### 
 echo "Archiving detail log \n"
 mv detail.log detail.log`date +%m%d%y%H%M%S`

 ### Archive detail log ###
 ls -t detail.log*|awk ' BEGIN  { cmd_str = "rm -f " } NR > 7 { cmd_str= cmd_str $0 " "} END { system(cmd_str); } '
 RETCODE=$?
 if [ $RETCODE -ne 0 ]; then
  echo "ERROR: Error while deleting detail logs \n"
  exit 1
 fi
fi
 
### To clean up /tmp ###

echo "Deleting the /tmp logs \n"

find /tmp -type f -mtime +7 -exec rm -f {} \; > /dev/null 2>&1

echo "Clean up of infa logs is complete \n"
