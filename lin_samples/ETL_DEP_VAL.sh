#!/bin/bash
# This script validates ETL deployment

user=`/usr/bin/whoami`
env=`echo $1 | tr '[A-Z]' '[a-z]'`
env_uc=`echo $env | tr '[a-z]' '[A-Z]'`

psirelease_manifest=`egrep "BASE.RELEASE" /nas/apps/env/manifests/envManifest_${env}.txt | awk -F'=' '{print $2}'`
psirelease=`echo $psirelease_manifest  | tr '[A-Z]' '[a-z]'`
echo $psirelease

#### Validating the check out branch #######

#if grep  "Branch Value = $psirelease" "$INFA_HOME/install/etl_checkout.log"; then
#   tail $INFA_HOME/install/etl_checkout.log 
#else
#   echo "Please validate if checkout job run successfully or is it from the correct branch"
#   less $INFA_HOME/install/etl_checkout.log | grep "Branch Value"
#   exit 1
#fi

#### Validating PSI directory exist #####
if [ -d $INFA_HOME/install/$psirelease ]
then
    echo "Checked out from $psirelease"
    cd $INFA_HOME/install/$psirelease
    
else
   echo "$psirelease directory is missing.Please validate the branch where it was checked out"
   exit 1

fi
##VALIDATING Error log FILES
if [[ $psirelease =~ [g] ]]
then
echo "Checking only none_shared_workflows logs as its Global env"
a=`less $INFA_HOME/install/$psirelease/none_shared_workflows.log | grep "Failed to Import" | wc -l`
echo "$a import failures found from none_shared_workflows.log"

else 
echo "Checking all logs as its Non-global env"
a=`less $INFA_HOME/install/$psirelease/none_shared_workflows.log | grep "Failed to Import" | wc -l`
echo "$a import failures found from none_shared_workflows.log"
b=`less $INFA_HOME/install/$psirelease/common_shared_workflows.log | grep "Failed to Import" | wc -l`
echo "$b import failures found from common_shared_workflows.log"
c=`less $INFA_HOME/install/$psirelease/ds_shared_workflows.log  |grep  "Failed to Import" | wc -l`
echo "$c import failures found from ds_shared_workflows.log"
fi

if [ -s $INFA_HOME/install/$psirelease/etldeploment_error.log ]; then
 cat etldeploment_error.log
 #### copying files to nas #####
 # cp $INFA_HOME/install/$psirelease/* /nas/ 
exit 1
##else
##then
elif [ $a != 0 ]
then
less none_shared_workflows.log | grep "Failed to Import"
  exit 1
elif [ $b != 0 ]
then
less common_shared_workflows.log| grep "Failed to Import"
 exit 1
elif [ $c != 0 ]
 then
less ds_shared_workflows.log | grep "Failed to Import"
   exit 1
else
  echo "Below last 20 lines of the logs - $INFA_HOME/install/$psirelease/etldeployment.log"
   tail -20 $INFA_HOME/install/$psirelease/etldeployment.log
fi
