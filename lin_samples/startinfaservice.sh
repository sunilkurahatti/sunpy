#!/bin/sh

###################################################################
# Startup script for Informatica services. It pings the services
# for about 5 minutes and give up if it is not able to successfully 
# bring up the services
#
# Created By    : Ravikumar CP
# Date Created  : 03-03-2010
# Modified By   :
# Modified Date :03/03/2017 ,By Vipin( Adidng few Checks and Truncation of Informatica tables )
#
###################################################################

#### Checking the Configuration File ####

if [ -s $HOME/etlenvbuild.cfg ] ; then
   . /$HOME/etlenvbuild.cfg
else
   echo "Configuration file for the build is missing."
   exit 1
fi

#### Validating the user ####

user=`whoami`
user_env=`echo $user | sed 's/inf//g'`
if [ $user_env != $environment ]; then
 echo "Error:$user does not have permission to start Informatica Services. Use '$environment'inf user to start the services"
 exit 1
fi

########Checking if Informatica is already running########
nohup pmcmd getrunningsessionsdetails -sv ${user_env}_INT -d ${user_env}_INFDMN -u wf_runner -p wfrunner > ${user_env}_Inf_Up.log 2>&1 &
sleep 10
if [[  ! -s ${user_env}_Inf_Up.log ]]; then
echo "***************Testing Informatica Integration Service is Up and running**************"
PID=` ps -ef|grep wfrunner |grep -v grep |awk '{print $2}'`
kill -9 $PID
echo "**********Killing Informatica Integration services running in nohup as the same are not up ,going ahead for a clean stop and start**********"
rm ${user_env}_Inf_Up.log

#### Shutdown services ####
echo "***************Shutting Down Services*******************************"
$INFA_HOME/server/tomcat/bin/infaservice.sh shutdown > /dev/null

sleep 30

#### TRUNCATE ###########
echo "Truncate table in progress"

$PMExtProcDir/Truncate_INF_tables.sh  > /dev/null
RETCODE=$?
if [ $RETCODE -ne 0 ]; then
 echo "ERROR: Truncate has Errors"
fi

sleep 30

#### Startup the services ####
ps -ef|grep ${user_env}inf
echo "*******************************************Starting Up Services*****************************"
$INFA_HOME/server/tomcat/bin/infaservice.sh startup > /dev/null

RETCODE=$?
if [ $RETCODE -ne 0 ]; then
 echo "ERROR: Error while executing infaservices.sh script"
 exit 1
fi
inc_val=0
while [ $inc_val -le 4 ]
do
 sleep 60
 msg=`$INFA_HOME/server/bin/infacmd.sh Ping -dn $domain_name -sn "$environment"_int`
 RETCODE=$?
 if [ $RETCODE -ne 0 ]; then
  inc_val=`expr $inc_val + 1`
 else
  echo "\n Informatica services were brought up successfully in $environment \n"
  ps -ef|grep ${user_env}inf
  break
 fi
done

if [ $RETCODE -ne 0 ]; then
 echo "ERROR: Unable to start Informatica services in 5 minutes threshold period \n"
 echo "\n $msg \n"
 exit 1
fi

else
echo "Doing final Validation for startup as Informatica services are already up"
#### Ping services for about 5 minutes ####
inc_val=0
while [ $inc_val -le 4 ] 
do
 sleep 60
 msg=`$INFA_HOME/server/bin/infacmd.sh Ping -dn $domain_name -sn "$environment"_int`
 RETCODE=$?
 if [ $RETCODE -ne 0 ]; then
  inc_val=`expr $inc_val + 1`
 else
  echo "\n Informatica services were brought up successfully in $environment \n"
  break
 fi
done

if [ $RETCODE -ne 0 ]; then
 echo "ERROR: Unable to start Informatica services in 5 minutes threshold period \n"
 echo "\n $msg \n"
 exit 1
fi  
fi 
