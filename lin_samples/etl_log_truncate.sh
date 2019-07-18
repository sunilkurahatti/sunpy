#!/bin/sh

if [ -z "$INFA_HOME" ];then
   echo "\$INFA_HOME is not defined.....\n"
   echo "exit -1"
   exit -1
else
   install=$INFA_HOME/install
   ETL_HOME=$INFA_HOME/server/infa_shared
fi

if [ -z "$REP_ADMINPASS" ];then
   echo "\$REP_ADMINPASS is not defined.....\n"
   echo "exit -1"
   exit -1
fi

if [ -s $INFA_HOME/etlenvbuild.cfg ]; then
 . $INFA_HOME/etlenvbuild.cfg
else
 echo "Configuration file for the build is missing."
 exit -1
fi

if [ -s $INFA_HOME/etldeployment.cfg ]; then
 . /$INFA_HOME/etldeployment.cfg
else
 echo "Configuration file for the deployment is missing."
 exit -1
fi

dom_rep_password=`echo $domain_db_pass | tr [A-Z] [a-z]`

msg=`pmrep connect -r "$environment"_rep -d $domain_name -n Administrator -x $dom_rep_password`
RETCODE=$?
if [ $RETCODE -gt 0 ]
then
        echo "Repository Connection Failed with $msg"
        echo "Exit -1"
        exit -1
else
        echo "Repository connection successfull"
fi
trunc_date=`perl -e 'use POSIX qw/strftime/; print strftime("%m/%d/%Y %H:%M:%S", localtime (time() - 86400 * 60));'`
echo $trunc_date
msg=`pmrep truncatelog -t "$trunc_date"`

RETCODE=$?
if [ $RETCODE -gt 0 ]
then
        echo "ETL Log Truncation Failed with $msg"
        echo "Exit -1"
        exit -1
else
        echo "ETL Log Truncation successfull"
fi

exit 0
