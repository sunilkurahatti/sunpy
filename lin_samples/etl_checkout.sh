#!/bin/sh

#############################################################
# This is an wrapper script to etl_deployment.sh. This passes
# cut off time to check out ETL artifacts. Time being it is
# Hard coded to sysdate and 2 PM.
#
# Author:        Ravi Kumar CP
# Date Created:  08/26/2010
# Modified by:
# Modified date:
#
##############################################################


PRINT=`echo "\n Wrong Usage......\n"
       echo " The following parameters were received- "
       echo " \t ${1:-EMPTY}"
       echo " \t ${2:-EMPTY}"
       echo " \t ${3:-EMPTY}"
       echo " \t ${4:-EMPTY}"
       echo " \t ${5:-EPMTY}"
       echo " \t ${6:-EPMTY}"
       echo "\n Usage:"
       echo "etl_deployment_rearch.sh <ipaddress> <portnumber> <branch> <checkout_branch> <project> <cutofftime>"
       echo "Where"
       echo "ipaddress:<starteam server ip address> portnumber:<starteam server port number> branch:<env_rel> checkout_branch:<starteam branch> etl_project:<ETL deployable Project> cutoffdate:<Build cut off date like 'Jun 07, 2010'> cutofftime:<Build cut off time>\n"
       echo "Build cut off time is an optional parameter"`

error_print()
{
  if [ $1 -gt 0 ]
  then
   echo "Failed"
   echo "Error:$2" >> $logfile
   echo "\n$msg" >> $logfile
   echo "\n$2"
   echo $msg
   echo "Please refer log file $logfile"
   echo "Exit 1"
   exit 1
  fi
}

successlog_print()
{
  echo "$1" >> $logfile
  echo "\n $2" >> $logfile
}

if [ $# -ne 5 ] && [ $# -ne 6 ] && [ $# -ne 7 ];then
 echo "$PRINT\n"
 echo exit 1
 exit 1
fi

##VALIDATING .cfg FILES

if [ -s $INFA_HOME/etlenvbuild.cfg ]; then
 . $INFA_HOME/etlenvbuild.cfg
else
 echo "Build Configuration file is missing."
 exit 1
fi

if [ -s $INFA_HOME/etldeployment.cfg ]; then
 . /$INFA_HOME/etldeployment.cfg
else
 echo "Deployment Configuration file is missing."
 exit 1
fi

if [ -z "$INFA_HOME" ];then
   echo "\$INFA_HOME is not defined.....\n"
   echo "exit 1"
   exit 1
else
   install=$INFA_HOME/install
fi

##VALIDATING THE USER RUNNING THE DEPLOYMENT

user=`/usr/ucb/whoami`
if echo $user|grep -v 'inf' >/dev/null ;then
 echo "$user does not have permission to run script"
 echo "Please run with inf user"
 exit 1
fi

starteam_server=`echo "$1"|awk -F":" '{print $2}'`
starteam_port=`echo "$2"|awk -F":" '{print $2}'`
env_branch=`echo "$3"|awk -F":" '{print $2}'|tr [A-Z] [a-z]`
starteam_branch=`echo "$4"|awk -F":" '{print $2}'|tr [A-Z] [a-z]`
etl_project=`echo "$5"|awk -F":" '{print $2}'`


##CHECKING install directory

if [ ! -d $install ]
then
 mkdir $INFA_HOME/install
 RETCODE=$?
 if [ $RETCODE -ne 0 ]
 then
  echo "Error in creating install directory"
  exit 1
 fi
fi

if [ ! -d $install/"$env_branch" ]; then
 mkdir $install/$env_branch
 RETCODE=$?
 if [ $RETCODE -ne 0 ]; then
  echo "Error in creating $env_branch directory"
  exit 1
 fi
fi

location=$install/$env_branch
logfile=$location/etlcheckout.log

no_timestamp_checkout ()
{
   project=$etl_project
   #project_port=`echo $project_port_read|awk -F"," '{print $2}'`
   if [ -d $location/ETL/$project ]; then
    rm -rf $location/ETL/$project
   fi
   mkdir $location/ETL/$project
   cd $location/ETL/$project
   if [ $starteam_branch = "infa-etl" ]; then
    starteam_path=$project/$project
   else
    starteam_path=$project/"$starteam_branch"
   fi
   if echo $project|grep -w "custom-processing" >/dev/null; then
    msg=`/nas/apps/envhome/starteamCheckout.sh CUSTOM "$starteam_path" NONE`
    RETCODE=$?
    # *** START - Validate ST error code 102 for no files *************
    if [ $RETCODE -gt 0 ]; then
        msgSTOutputParse=`echo $msg | grep 'Return code: 102'`
        if [ $? -eq 0 ]; then
            # grep return more than 0 means, the "Return code 102 search failed in starteam checkout shell".
            # Which means skip to next folder
            RETCODE=0
        fi
    fi
    # *** END - Validate ST error code 102 for no files *************

    error_print $RETCODE "Error checking out $project" "$msg"
    successlog_print "\n $msg " "\n Successfully checked out $project from star team...........\n"
   else
    msg=`/nas/apps/envhome/starteamCheckout.sh BUILD "$starteam_path" NONE`
    RETCODE=$?
    # *** START - Validate ST error code 102 for no files *************
    if [ $RETCODE -gt 0 ]; then
        msgSTOutputParse=`echo $msg | grep 'Return code: 102'`
        if [ $? -eq 0 ]; then
            # grep return more than 0 means, the "Return code 102 search failed in starteam checkout shell".
            # Which means skip to next folder
            RETCODE=0
        fi
    fi
    # *** END - Validate ST error code 102 for no files *************

    error_print $RETCODE "Error checking out $project" "$msg"
    successlog_print "\n $msg " "\n Successfully checked out $project from star team...........\n"
   fi
}

timestamp_checkout ()
{
  ## It is hard coded to 2:00 PM until it is parameterized from control m ##
  datetime=`date|awk -F" " '{print $2,$3",",$6,"2:00:00 PM"}'`
   project=$etl_project
   #project_port=`echo $project_port_read|awk -F"," '{print $2}'`
   if [ -d $location/ETL/$project ]; then
    rm -rf $location/ETL/$project
   fi
   mkdir $location/ETL/$project
   cd $location/ETL/$project
   if [ $starteam_branch = "infa-etl" ]; then
    starteam_path=$project/$project
   else
    starteam_path=$project/"$starteam_branch"
   fi
   if echo $project | grep -w "custom-processing" >/dev/null; then
    msg=`/nas/apps/envhome/starteamCheckoutByTimeStamp.sh CUSTOM "$starteam_path" NONE "$cutofftime"`
    RETCODE=$?
    # *** START - Validate ST error code 102 for no files *************
    if [ $RETCODE -gt 0 ]; then
        msgSTOutputParse=`echo $msg | grep 'Return code: 102'`
        if [ $? -eq 0 ]; then
            # grep return more than 0 means, the "Return code 102 search failed in starteam checkout shell".
            # Which means skip to next folder
            RETCODE=0
        fi
    fi
    # *** END - Validate ST error code 102 for no files *************

    error_print $RETCODE "Error checking out $project" "$msg"
    successlog_print "\n $msg " "\n Successfully checked out $project from star team...........\n"
   else
    msg=`/nas/apps/envhome/starteamCheckoutByTimeStamp.sh BUILD "$starteam_path" NONE "$cutofftime"`
    RETCODE=$?
    # *** START - Validate ST error code 102 for no files *************
    if [ $RETCODE -gt 0 ]; then
        msgSTOutputParse=`echo $msg | grep 'Return code: 102'`
        if [ $? -eq 0 ]; then
            # grep return more than 0 means, the "Return code 102 search failed in starteam checkout shell".
            # Which means skip to next folder
            RETCODE=0
        fi
    fi
    # *** END - Validate ST error code 102 for no files *************

    error_print $RETCODE "Error checking out $project" "$msg"
    successlog_print "\n $msg " "\n Successfully checked out $project from star team...........\n"
   fi
}

echo "Info: Checking out list file, shared objects from build folder" >> $logfile
if [ -d $location/ETL/infa-etl ]; then
 rm -rf $location/ETL/infa-etl
fi
mkdir -p $location/ETL/infa-etl
cd $location/ETL/infa-etl
msg=`/nas/apps/envhome/starteamCheckout.sh BUILD infa-etl/"$starteam_branch" NONE`
RETCODE=$?
error_print $RETCODE $error_status "Error checking out list file" "$msg"
successlog_print "\n $msg " "\n Successfully checked out infa-etl from star team...........\n"

if [ $# -eq 6 ] || [ $# -eq 7 ];then
 cutofftime_temp=`echo "$6"|awk -F":" '{print $2}'`
 if [ $# -eq 7 ];then
        TIME=`echo "$7"|awk -F":" '{print $2":"$3}'`
 else
        TIME=`echo "02:00 PM"`
 fi
cutofftime=${cutofftime_temp}" "${TIME}

 if test -n "cutofftime" ; then
  cutofftime_temp=`echo "$6"|awk -F":" '{print $2}'`
  if [ $# -eq 7 ];then
        TIME=`echo "$7"|awk -F":" '{print $2":"$3}'`
  else
        TIME=`echo "02:00 PM"`
  fi
cutofftime=${cutofftime_temp}" "${TIME}

 else
  cutofftime=`date|awk -F" " '{print $2,$3",",$6,"2:00:00 PM"}'`
 fi
 timestamp_checkout
else
 no_timestamp_checkout
fi

exit 0