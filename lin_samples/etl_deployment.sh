#!/bin/ksh
#############################################################################################
# This script is used to check out ETL deployable artifcts from star team
# to deploy into an environment.
# 
# Author:          Ravikumar
# Date Created:    02/15/2010
# Modified by:     Lijju Mathew
# Date Modified:   03/03/2014
#############################################################################################

PRINT=`echo -e "\n Wrong Usage......\n"
       echo -e " The following parameters were received- "
       echo -e " \t ${1:-EMPTY}"
       echo -e " \t ${2:-EMPTY}"
       echo -e "\n Usage:"
       echo -e "etl_deployment.sh <branch> <listfile>"
       echo -e "Where"
       echo -e "branch:<starteam branch> listfile:<ETL deployable artifact list file>"`

##error function

error_logprint()
{
  echo -e "$1" >> $errorlog
  echo -e "\n $2" >> $errorlog
}

error_print()
{ 
  if [ $1 -gt 0 ]
  then
   echo -e "Failed"
   echo -e "error_status=$2" > $errstatus_log 
   echo -e "`date` Error:$3" >> $logfile 
   echo -e "\n$msg" >> $logfile
   echo -e "\n$3"
   echo -e $msg
   echo -e "Please refer log file $logfile"
   rm -rf $templog
   echo -e "Exit 1"
   exit 1
  else
   echo -e "error_status=$2">$errstatus_log
  fi
}

successlog_print()
{
  echo -e "`date`: $1" >> $logfile
  echo -e "\n`date`: $2" >> $logfile
}

##VALIDATING THE PARAMETERS

if [ $# -lt 2 ] || [ $# -gt 2 ]
then
 echo -e "$PRINT\n"
 exit 1
fi

if [ -z "$INFA_HOME" ];then
   echo -e "\$INFA_HOME is not defined.....\n"
   echo -e "exit 1"
   exit 1
else
   install=$INFA_HOME/install
   ETL_HOME=$INFA_HOME/server/infa_shared
fi

##VALIDATING .cfg FILES

if [ -s $INFA_HOME/etlenvbuild.cfg ]; then
 . $INFA_HOME/etlenvbuild.cfg
else
 echo -e "Configuration file for the build is missing."
 exit 1
fi

if [ -s $INFA_HOME/etldeployment.cfg ]; then
 . /$INFA_HOME/etldeployment.cfg
else
 echo -e "Configuration file for the deployment is missing."
 exit 1
fi

##VALIDATING THE USER RUNNING THE DEPLOYMENT

user=`/usr/bin/whoami`
if echo -e $user|grep -v 'inf' >/dev/null ;then
 echo -e "$user does not have permission to run script"
 echo -e "Please run with inf user"
 exit 1
fi

##CHECKING install directory

if [ ! -d $install ] 
then
 mkdir $INFA_HOME/install
 RETCODE=$?
 if [ $RETCODE -ne 0 ]
 then
  echo -e "Error in creating install directory under $INFA_HOME"
  exit 1
 fi
fi

starteam_branch=`echo -e "$1"|awk -F":" '{print $2}'|tr [A-Z] [a-z]`
list_file=`echo -e "$2"|awk -F":" '{print $2}'`

if [ ! -d $install/"$starteam_branch" ]; then
 mkdir $install/$starteam_branch
 RETCODE=$?
 if [ $RETCODE -ne 0 ]; then
  echo -e "Error in creating $starteam_branch directory under $install"
  exit 1
 fi
fi

location=$install/$starteam_branch 
logfile=$location/etldeployment.log
env_logfile=$location/envIronmentalize_configGen.log
errorlog=$location/etldeployment_error.log
errstatus_log=$location/etldeployment_errstatus.log
templog=$location/temp.log
basedir=$PMExtProcDir
dom_rep_password=`echo -e $domain_db_pass | tr A-Z a-z`

if [ -s $errstatus_log ]; then
 error_status=`awk 'BEGIN{FS="="}/error_status/ {print $2}' $errstatus_log`
 echo -e "\n`date` Info: Performing deployment from the previous failure step" >> $logfile
else
 error_status=0
 echo -e "`date` Info: Performing ETL deployment for $environment - `date`" > $logfile
 echo -e "`date` Info: Performing ETL deployment from scratch" >> $logfile
fi

if [ $error_status -eq 0 ]; then
 find $location/ETL/infa-etl -type d \( -name "paramfiles" -o -name "ExtProc" -o -name "SrcFiles" -o -name "TgtFiles" -o -name "Workflows" \)|grep -vw "Workflows">$location/FilesFolder_path.lst
 RETCODE=$?
 error_print $RETCODE $error_status "Error:while getting folder paths for Shared Object SrcFiles, TgtFiles, paramfiles...etc"
 find $location/ETL/infa-etl -type d \( -name "paramfiles" -o -name "ExtProc" -o -name "SrcFiles" -o -name "TgtFiles" -o -name "Workflows" \)|grep -w "Workflows" >$location/WorkflowsFolder_path.lst
 RETCODE=$?
 error_print $RETCODE $error_status "Error: while getting folder paths for Shared Object Workflows"
 
 successlog_print "***********Regenerating etldeployment.cfg configuration file***************" "\n"
 global_flag=`echo -e $env | sed -e "s/^.\(.\).*$/\1/"`
 echo -e "`date` Info:Global $global_flag $env" >> $logfile
# if [ `expr "$global_flag" : "[a-z]*$"` -ne 0 ]; then
 	#/nas/apps/envhome/unix/env/envIronmentalize.pl -i -e ${env} -t $location/ETL/infa-etl/Build/etldeployment.cfg.template.global -o $INFA_HOME/etldeployment.cfg >> $env_logfile
# 	RETCODE=$?
# 	error_print $RETCODE $error_status "Error: while regenerating etldeployment.cfg file"
# else
 	#/nas/apps/envhome/unix/env/envIronmentalize.pl -i -e ${env} -t $location/ETL/infa-etl/Build/etldeployment.cfg.template -o $INFA_HOME/etldeployment.cfg >> $env_logfile
# 	RETCODE=$?

# 	error_print $RETCODE $error_status "Error: while regenerating etldeployment.cfg file"
#fi

 if [ -s $location/ETL/infa-etl/Build/$list_file ]; then
  echo -e "`date` Info: Deploying projects from list file" >> $logfile
  exec < $location/ETL/infa-etl/Build/"$list_file"
  while read project_port_read;
  do
   project=`echo -e $project_port_read|awk -F"," '{print $1}'`
   project_port=`echo -e $project_port_read|awk -F"," '{print $2}'`
   if [ -d $location/ETL/$project ]; then
    find $location/ETL/$project -type d \( -name "paramfiles" -o -name "ExtProc" -o -name "SrcFiles" -o -name "TgtFiles" -o -name "Workflows" \)|grep -vw "Workflows" >>$location/FilesFolder_path.lst
    #RETCODE=$?
    #error_print $RETCODE $error_status "Error:while getting folder paths for SrcFiles, TgtFiles, paramfiles...etc"
    find $location/ETL/$project -type d \( -name "paramfiles" -o -name "ExtProc" -o -name "SrcFiles" -o -name "TgtFiles" -o -name "Workflows" \)|grep -w "Workflows" >>$location/WorkflowsFolder_path.lst
    #RETCODE=$?
    #error_print $RETCODE $error_status "Error: while getting folder paths for Workflows"
   fi
  done
  #find $location/ETL -type d \( -name "TechDocs" -o -name "UnitTestPlans" -o -name "DataIntgDocs" \) -exec rm -rf {} \;
  RETCODE=$?
  error_print $RETCODE $error_status "Error:while deleting Techdocs, Unit TestPlans and DataIntgDocs"
  error_status=1
 else
  error_print 1 $error_status "Error:List file $list_file not found in $starteam_branch"
 fi
fi

cd $location
while [ $error_status -le 3 ]
do
 case $error_status in
   
  1)
    if [ `grep '^sqlserver' $INFA_HOME/etldeployment.cfg|wc -l` -ge 1 ]
    then
     echo -e "`date` Info: Creating odbc.ini file" >> $logfile
     if [ ! -f $location/ETL/infa-etl/Build/odbcini.template ]; then
      error_print 1 $error_status "Error: odbcini.template was not checkedout"
     fi
     if [ ! -f $INFA_HOME/ODBC7.0/odbc.ini ]; then
      touch $INFA_HOME/ODBC7.0/odbc.ini
      RETCODE=$?
      error_print $RETCODE $error_status "Error: while creating odbc.ini file in $INFA_HOME/ODBC7.0/"
     fi
     cat $INFA_HOME/etldeployment.cfg|grep '^sqlserver_connection'|awk '{FS="="}{print $2}'|while read sqlconnection;
     do
      odbc_connection=`echo -e $sqlconnection|awk -F":" '{print $1}'`"_"$environment
      if echo -e $odbc_connection|grep -w "$odbc_connection" $INFA_HOME/ODBC7.0/odbc.ini>/dev/null ; then
       successlog_print "\n $odbc_connection connection entry already present in odbc.ini file ......" "\n"
      else
       server=`echo -e $sqlconnection|awk -F":" '{print $2}'`
       user_name=`echo -e $sqlconnection|awk -F":" '{print $3}'`
       password=`echo -e $sqlconnection|awk -F":" '{print $4}'` 
       database=`echo -e $sqlconnection|awk -F":" '{print $5}'`
       envinf=$environment"inf" 
       cat $location/ETL/infa-etl/Build/odbcini.template|sed "-e s/\$odbc_connection/$odbc_connection/g" "-e s/\$envinf/$envinf/g" "-e s/\$server/$server/g" "-e s/\$database/$database/g" "-e s/\$user_name/$user_name/g" "-e s/\$password/$password/g">> $INFA_HOME/ODBC7.0/odbc.ini
       RETCODE=$?
       error_print $RETCODE $error_status "Error: creating odbc.ini file"
       echo -e "\n" >> $INFA_HOME/ODBC7.0/odbc.ini 
      fi
     done
     successlog_print "\n odbc.ini file has been deployed in $INFA_HOME/ODBC7.0/ folder............." "\n"
    fi
    error_status=2
    error_print 0 $error_status 
   ;;
  
  2)
     
    echo -e "`date` Info: Listing conections" >> $logfile
    msg=`pmrep connect -r "$environment"_rep -d $domain_name -n Administrator -x $dom_rep_password`
    RETCODE=$?
    error_print $RETCODE $error_status "Error connecting to the repository $environment" "$msg"
    
    successlog_print "***************************************************************************\n" "...........Starting the creation of Connections in $environment_rep  Repository.............\n"
    
    `pmrep listconnections>$templog`   
    RETCODE=$?
    if [ $RETCODE -ne 0 ]; then msg=`cat $templog`; fi
     
    error_print $RETCODE $error_status "Error listing connections in $environment_rep" $msg
    
    cat $INFA_HOME/etldeployment.cfg|grep '^oracle_connection'|awk -F= '{print $2}'|sed '1{/^$/d}'|while read oracleconnection;
    do
     connection_name=`echo -e $oracleconnection|awk -F":" '{print $1}'`
     if [ `grep "$connection_name,relational" $templog|wc -l` -eq 1 ]; then
      successlog_print "A Connection with the name $connection_name already exists" "\n"
     else
      connection_type="Oracle"
      user_name=`echo -e $oracleconnection|awk -F: '{print $2}'`
      password=`echo -e $oracleconnection|awk -F: '{print $3}'`
      connect_string=`echo -e $oracleconnection|awk -F: '{print $4}'`
     
      msg=`pmrep createconnection -s $connection_type -n $connection_name -u $user_name -p $password -c $connect_string -l "$conn_codepage" -e "$environment_sql"`
      RETCODE=$?
       
      error_print $RETCODE $error_status "Error creating connection $connection_name" $msg

      if [ $RETCODE -eq 0 ]; 
         then 
	     msg=`pmrep AssignPermission -o Connection -t Relational -n $connection_name -u wf_runner -p rx`
       fi
     
      successlog_print "Connection $connection_name is created successfully" "\n"
      
     fi
    done
    
    cat $INFA_HOME/etldeployment.cfg|grep '^sqlserver_connection'|awk '{FS="="}{print $2}'|sed '1{/^$/d}'|while read sqlconnection;
    do
     connection_name=`echo -e $sqlconnection|awk -F: '{print $1}'`
     if [ `grep "$connection_name,relational" $templog|wc -l` -eq 1 ]; then
      successlog_print "A Connection with the name $connection_name already exists" "\n"
     else
      connection_type="ODBC"
      user_name=`echo -e $sqlconnection|awk -F: '{print $3}'`
      password=`echo -e $sqlconnection|awk -F: '{print $4}'`
      connect_string=$connection_name"_"$environment
      msg=`pmrep createconnection -s $connection_type -n $connection_name -u $user_name -p $password -c $connect_string -l "$conn_codepage"`
      RETCODE=$?
      
      error_print $RETCODE $error_status "Error creating connection $connection_name" $msg
      
      if [ $RETCODE -eq 0 ]; 
        then 
           msg=`pmrep AssignPermission -o Connection -t Relational -n $connection_name -u wf_runner -p rx`
        fi
      
      successlog_print "Connection $connection_name is created successfully" "\n"
     
     fi   
    done
    
    error_status=3
    
    error_print 0 $error_status
   ;;
    
  3)
     
   if [ -s $location/FilesFolder_path.lst ]
   then

    awk -F"/"  ' { cmd_str="cp -r " } { if ($10=="reg")  { system ( cmd_str "\"" $0 "\"  $PWX_HOME" ); } else { system ( cmd_str "\"" $0 "\" $PMRootDir" ); } } ' $location/FilesFolder_path.lst 
    RETCODE=$?

    error_print $RETCODE $error_status "Error:Copying paramfiles, Extproc, Srcfiles, Tgtfiles etc... into $ETL_HOME"
    successlog_print "Successfully copied paramfiles, Extproc, Srcfiles, TgtFiles etc....into infa_shared directory" "\n"

    find $ETL_HOME/ExtProc/ -type f -exec chmod 755 {} \;
    RETCODE=$?

    error_print $RETCODE $error_status "Error in changing the permission for scripts in $ETL_HOME/ExtProc/"
    successlog_print "Grant the execute permission for scripts in $ETL_HOME/ExtProc/" "\n"
    echo -e "\n`date`: All the ETL artifacts are successfully deployed in the unix file system......\n">>$logfile

   else

    echo -e "`date`: No unix files checked out and nothing is deployed into Unix file system" >> $logfile  
   fi
    
   error_status=4
    
   error_print 0 $error_status
   ;;
 esac
done

##Removing File lists########

rm -rf $location/FilesFolder_path.lst

####calling repository deployment script#########

sh $basedir/repo_deployment.sh $location
