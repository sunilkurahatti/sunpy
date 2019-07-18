#!/bin/sh
#set -x
################################################################################################
# This script is used for creating repository folders, deploying workflows and validating the
# workflows
# Author:       Ravikumar CP
# Date Created: 02/19/2010
#
# Date Modified:
#
#
##################################################################################################

if [ -z $INFA_HOME ]; then
 echo -e "$INFA_HOME is not defined...\n"
 echo -e "exit 1"
 exit 1
else
 install=$INFA_HOME/install
 ETL_HOME=$INFA_HOME/server/infa_shared
fi

if [ -s $INFA_HOME/etlenvbuild.cfg ]; then
 . $INFA_HOME/etlenvbuild.cfg
else
 echo -e "etlenvbuild.cfg is not present in $INFA_HOME.."
 echo -e "exit 1"
 exit 1
fi

if [ -s $INFA_HOME/etldeployment.cfg ]; then
 . $INFA_HOME/etldeployment.cfg
else
 echo -e "etldeployment.cfg is not present in $INFA_HOME..."
 echo -e "exit 1"
 exit1
fi

location=$1
logfile=$location/etldeployment.log
errorlog=$location/etldeploment_error.log
errstatus_log=$location/etldeployment_errstatus.log
templog=$location/temp.log
basedir=$PMExtProcDir
dom_rep_password=`echo -e $domain_db_pass | tr [A-Z] [a-z]`

errorlog_print()
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
   echo -e "$msg"
   echo -e "Please refer the $logfile"
   rm -rf $templog
   echo -e "Exit 1"
   exit 1
  else
   echo -e "error_status=$2" > $errstatus_log
  fi

}

deploy_folder()
{
    sleep 20
	file_list=$1
	deploy_log_file=`echo -e $file_list | sed 's/.lst/.log/g'`
	deploy_err_file=`echo -e $file_list | sed 's/.lst/.err/g'`
	
	successlog_print "Starting deployment - $file_list." "\n" "$deploy_log_file"
	msg=`pmrep connect -r "$environment"_rep -d $domain_name -n Administrator -x $dom_rep_password`
    RETCODE=$?
	if [ $RETCODE -ne 0 ]
    then
		echo -e "Error while connecting to repository.........\n" >> $deploy_err_file
	fi
	
	cd $location
	exec<$file_list
    while read workflow_code;
    do
		#Retrieving target folder name and workflow name
		appfolder=`echo -e "$workflow_code"|cut -d"/" -f9`
		workflow=`echo -e "$workflow_code"|cut -d"/" -f11`
		
		#Replacing intergration service with $environemnt_int
		intservice="$environment"_int
		cp "$workflow_code" "$location"
		perl -pi -e "s/SERVERNAME =\".*_int\"/SERVERNAME=\"$intservice\"/g" "$workflow"
		RETCODE=$?
        if [ $RETCODE -ne 0 ]
        then
			echo -e " Error in replacing integration service for $workflow in $appfolder..\n"  >> $deploy_err_file
			rm -f "$workflow"
		fi
	
	    workflow_controlfile=import_controlfile_"$workflow"
	
		#Replacing the folder and repository name with the target folder name and target repository name in the control file
		awk -F"\"" -v workflow_controlfile=$workflow_controlfile -v location=$location -v targetrep="$environment"_rep ' BEGIN { cmd_str= " sed "} /<REPOSITORY NAME/ {sourcerep=$2} /<FOLDER NAME/ {cmd_str = cmd_str " -e '\''/FOLDER NAME/a\\\n" "<FOLDERMAP SOURCEFOLDERNAME=\""$2"\" SOURCEREPOSITORYNAME=\""sourcerep"\" TARGETFOLDERNAME=\""$2 "\" TARGETREPOSITORYNAME=\""targetrep"\" /> '\''"; } END { cmd_str= cmd_str " " location"/ETL/infa-etl/Build/import_controlfile.xml > " location"/"workflow_controlfile ; system (cmd_str);} ' "$workflow"
    
		RETCODE=$?
		if [ $RETCODE -ne 0 ]
		then
			errorlog_print " Error in replacing integration service for $workflow in $appfolder..\n" >> $deploy_err_file
			rm -f "$workflow"
		fi	
		
		# importing workflow to the target repository
		msg=`pmrep objectimport -i "$workflow" -c import_controlfile_"$workflow"`
			
		RETCODE=$?
		if [ $RETCODE -ne 0 ]
		then
			echo -e "Error importing workflow - $workflow \n" >> $deploy_err_file
			echo -e "$msg" >> $deploy_err_file
			
			rm -f "$workflow"
			rm -f import_controlfile_"$workflow"
		else
		    echo -e "$msg" >> $deploy_log_file
			echo -e "Successfully imported workflow - $workflow \n" >> $deploy_log_file
			rm -f "$workflow"
			rm -f import_controlfile_"$workflow"
		fi 
	done
	echo -e "Completed deployment - $file_list. \n" >> $deploy_log_file
	
}

successlog_print()
{
  echo -e "`date` $1" >> $logfile
  echo -e "\n`date` $2" >> $logfile
}

if [ -s $errstatus_log ]; then
 error_status=`awk 'BEGIN{FS="="}/error_status/ {print $2}' $errstatus_log`
 RETCODE=$?
 error_print $RETCODE $error_status "Error: while retrieving error_status from error log"
else
 error_status=4
fi

if [ ! -f $location/ETL/infa-etl/Build/import_controlfile.xml ];then
 error_print 1 $error_status "import_control.xml file was not checked out"
fi
if [ -f $location/ETL/infa-etl/Build/impcntl.dtd ]; then
 cp $location/ETL/infa-etl/Build/impcntl.dtd $location
else
 error_print 1 $error_status "impcntl.dtd file was not checked out.."
fi

cd $location

while [ $error_status -le 9 ]
do
 case $error_status in

 4) 
   
   ##Listing all the folders to create in repository
   if [ -s $location/WorkflowsFolder_path.lst ]
   then
    cut -f9 -d'/' $location/WorkflowsFolder_path.lst|uniq > $location/RepFolder.lst
    RETCODE=$?
    error_print $RETCODE $error_status "Error:Listing repository folders from unix file system..."

    echo -e "`date` Info: connecting to repository to list folders" >>$logfile
    msg=`pmrep connect -r "$environment"_rep -d $domain_name -n Administrator -x $dom_rep_password`
    RETCODE=$?
    error_print $RETCODE $error_status "Error while connecting to repository" "$msg"
    successlog_print "Connected to $environment_rep Repository......" "\n"
    successlog_print "***************************************************************************\n" "...........Starting the creation of Folders in "$environment"_rep Repository.............\n"
    msg=`pmrep listobjects -o folder>$templog`
    RETCODE=$?
    if [ $RETCODE -ne 0 ]; then msg=`cat $templog`; fi

    error_print $RETCODE $error_status "Error listing folders from repository" "$msg"
    exec < $location/RepFolder.lst
    while read Folder;
    do
     if cat $templog|grep -w "^$Folder">/dev/null
     then
      successlog_print "A folder with the name $Folder already exists" "\n"
     elif [ "$Folder" = "Shared Objects" -o "$Folder" = "DS Shared Objects" -o "$Folder" = "Global Shared Objects" ]
     then
      msg=`pmrep createfolder -n "$Folder" -o Administrator -s shared -p 774`
      RETCODE=$?
      if [ $RETCODE -ne 0 ]
      then
       if echo -e $msg|grep "A folder with name $Folder already exists in repository">/dev/null
       then
        successlog_print "A folder with name $Folder already exists in repository" "\n"
       else
        error_print $RETCODE $error_status "Error while creating $Folder..." "$msg"
       fi
      else
       successlog_print "$Folder folder is created successfully......" "\n"
      fi
     else
      msg=`pmrep createfolder -n "$Folder" -o Administrator -p 775`
      RETCODE=$?
      if [ $RETCODE -ne 0 ]
      then
       if echo -e $msg|grep "A folder with name $Folder already exists in repository">/dev/null
       then
        successlog_print "A folder with name $Folder already exists in repository" "\n"
       else
        error_print $RETCODE $error_status "Error while creating $Folder" "$msg"
       fi
      else
       successlog_print "$Folder folder is created successfully......" "\n"
      fi
     fi
    done
   fi
   rm -f $location/RepFolder.lst
   error_status=5

   error_print 0 $error_status
  ;;

 5)
   
   ## Deploying Shared objects########
   if [ -s $location/WorkflowsFolder_path.lst ]
   then
    if cat $location/WorkflowsFolder_path.lst|grep "/Shared Objects/" > /dev/null
    then
     find $location/ETL/infa-etl/"Shared Objects"/Workflows -type f -name "*" | sort -u >$location/Shared_Workflows.lst
     RETCODE=$?
     error_print $RETCODE $error_status "Error listing Shared objects"
    fi
    if cat $location/WorkflowsFolder_path.lst|grep "/DS Shared Objects/" > /dev/null
    then
     find $location/ETL/infa-etl/"DS Shared Objects"/Workflows -type f -name "*" | sort -u >>$location/Shared_Workflows.lst
     RETCODE=$?
     error_print $RETCODE $error_status "Error listing DS Shared objects"
    fi
	if cat $location/WorkflowsFolder_path.lst|grep "/Global Shared Objects/" > /dev/null
    then
     find $location/ETL/infa-etl/"Global Shared Objects"/Workflows -type f -name "*" | sort -u >>$location/Shared_Workflows.lst
     RETCODE=$?
     error_print $RETCODE $error_status "Error listing Global Shared objects"
    fi
    if [ -s $location/Shared_Workflows.lst ]
    then
     successlog_print "................Starting the deployment of Shared Objects....................." "\n"
     msg=`pmrep connect -r "$environment"_rep -d $domain_name -n Administrator -x $dom_rep_password`
     RETCODE=$?
     error_print $RETCODE $error_status "Error connecting to repository" "$msg"
     exec < $location/Shared_Workflows.lst
     while read sharedobject;
     do
      repfolder=`echo -e $sharedobject|cut -d"/" -f9`
      workflow=`echo -e $sharedobject|cut -d"/" -f11`

      cp "$sharedobject" "$location"

      #Replacing the folder and repository name with the target folder name and target repository name in the control file
      awk -F"\"" -v location=$location -v targetrep="$environment"_rep ' BEGIN { cmd_str= " sed "} /<REPOSITORY NAME/ {sourcerep=$2} /<FOLDER NAME/ {cmd_str = cmd_str " -e '\''/FOLDER NAME/a\\\n" "<FOLDERMAP SOURCEFOLDERNAME=\""$2"\" SOURCEREPOSITORYNAME=\""sourcerep"\" TARGETFOLDERNAME=\""$2 "\" TARGETREPOSITORYNAME=\""targetrep"\" /> '\''"; } END { cmd_str= cmd_str " " location"/ETL/infa-etl/Build/import_controlfile.xml > " location"/import_controlfile.xml " ; system (cmd_str);} ' "$workflow"
      RETCODE=$?
      error_print $RETCODE $error_status "Error while updating folder in control file for shared object $workflow..."
      successlog_print "\n" "\n importing the $workflow to folder $repfolder ..........."
      msg=`pmrep objectimport -i "$workflow" -c import_controlfile.xml`
      RETCODE=$?
      rm -f "$workflow"
      error_print $RETCODE $error_status "Error while importing shared object $workflow..." "$msg"
      successlog_print "\n Importing the $workflow to folder $repfolder is successful...................\n*******************************************************************\n" "$msg \n*******************************************************************\n"
     done
     successlog_print "All Shared Objects are imported successfully....... \n"  "********************************************************************************\n"
    fi
    rm -f $location/import_controlfile.xml
    rm -f $location/Shared_Workflows.lst
   fi

   error_status=6

   error_print 0 $error_status
  ;;

 6)
   
   ##Deploying all application workflows######
   if [ -s $location/WorkflowsFolder_path.lst ]
   then
		rm -rf $location/Workflows.lst
		cp $location/ETL/infa-etl/Build/impcntl.dtd $location
		#Generate workflow list based on shared objects used in the workflow
        exec < $location/WorkflowsFolder_path.lst
		while read workflow_folder;
		do
			if echo -e "$workflow_folder" | grep -vw "Shared Objects" >/dev/null
			then
				find "$workflow_folder" -type f -name "*" | sort -u >> $location/Workflows.lst
				RETCODE=$?
				error_print $RETCODE $error_status "Error while listing workflows" "\n"
				common_count=`find "$workflow_folder" -type f -exec grep -l 'FOLDERNAME ="Shared Objects"'  {} \; | wc -l`
				ds_count=`find "$workflow_folder" -type f -exec grep -l 'FOLDERNAME ="DS Shared Objects"'  {} \; | wc -l`
		         
				
				if [ $common_count -gt 0 ] ; then
					find "$workflow_folder" -type f -name "*" | sort -u >> $location/common_shared_workflows.lst
					RETCODE=$?
					error_print $RETCODE $error_status "Error while listing workflows with common shared objects" "\n"
				
				elif [ $ds_count -gt 0 ] ; then
					find "$workflow_folder" -type f -name "*" | sort -u >> $location/ds_shared_workflows.lst
					RETCODE=$?
					error_print $RETCODE $error_status "Error while listing workflows with ds shared objects" "\n"
				else
					find "$workflow_folder" -type f -name "*" | sort -u >> $location/none_shared_workflows.lst
					RETCODE=$?
					error_print $RETCODE $error_status "Error while listing workflows with no shared objects" "\n"
				fi
			fi
		done
		
		if [ -s $location/Workflows.lst ]
		then
			rm -f $errorlog

			# ------------------------------------------------------------------------
			# START - Substitue Workflow (wf***.XML) file with configurable value from workflowconfig.xml file
			saveCurrPath=`pwd`
			cd $location/ETL/infa-etl/Build
			exec<$location/Workflows.lst
			while read workflow_code;
			do
				echo -e INFO: CALLING perl applyWorkFlowConfig.pl "WFFileName=$workflow_code"
				perl applyWorkFlowConfig.pl "WFFileName=$workflow_code"
				PERLEXITCODE=$?
				echo -e "PERLEXITCODE : PERLEXITCODE : PERLEXITCODE : PERLEXITCODE : $PERLEXITCODE"
				if [ $PERLEXITCODE -ne 0 ]
				then
					errorlog_print "Error replacing workflow config in  $workflow_code"
					errorlog_print $PERLEXITCODE "Error replacing workflow config in  $workflow_code "
			   fi
			done
			cd $saveCurrPath
			# END OF - Substitue Workflow (wf***.XML) file with configurable value from workflowconfig.xml file
			# ------------------------------------------------------------------------
		fi
        
		
		common_shared_workflows_exists=0
		ds_shared_workflows_exists=0
		none_shared_workflows_exists=0
		 
		if [ -s $location/common_shared_workflows.lst ] ; then
			deploy_folder $location/common_shared_workflows.lst &
			pid_common_shared_workflows=$!
			echo -e "Deployment of workflows with common shared objects started - pid:$pid_common_shared_workflows\n"
			successlog_print "Deployment of workflows with common shared objects started" "\n"
			common_shared_workflows_exists=1
		fi

		if [ -s $location/ds_shared_workflows.lst ] ; then
			deploy_folder $location/ds_shared_workflows.lst &
			pid_ds_shared_workflows=$!
			echo -e "Deployment of workflows with ds shared objects started - pid:$pid_ds_shared_workflows\n"
			successlog_print "Deployment of workflows with ds shared objects started" "\n"
			ds_shared_workflows_exists=1
		fi

		if [ -s $location/none_shared_workflows.lst ] ; then
			deploy_folder $location/none_shared_workflows.lst &
			pid_none_shared_workflows=$!
			echo -e "Deployment of workflows with no shared objects started - pid:$pid_none_shared_workflows\n"
			successlog_print "Deployment of workflows with no shared objects started" "\n"
			none_shared_workflows_exists=1
		fi

			
		if [ $common_shared_workflows_exists -eq 1 ] ; then
			successlog_print "Waiting for deployment of workflows with common shared objects to complete" "\n"
			echo -e "Waiting for common shared objects workflows- pid:$pid_common_shared_workflows\n"
			wait $pid_common_shared_workflows
			successlog_print "Deployment of workflows with common shared objects completed" "\n"
			rm -f $location/common_shared_workflows.lst
		fi

		if [ $ds_shared_workflows_exists -eq 1 ] ; then
			successlog_print "Waiting for deployment of workflows with ds shared objects to complete" "\n"
			echo -e "Waiting for ds shared objects workflows- pid:$pid_ds_shared_workflows\n"
			wait $pid_ds_shared_workflows
			successlog_print "Deployment of workflows with ds shared objects completed" "\n"
			rm -f $location/ds_shared_workflows.lst
		fi

		if [ $none_shared_workflows_exists -eq 1 ] ; then
			successlog_print "Waiting for deployment of workflows with no shared objects to complete" "\n"
			echo -e "Waiting for no shared objects workflows- pid:$pid_none_shared_workflows\n"
			wait $pid_none_shared_workflows
			successlog_print "Deployment of workflows with no shared objects completed" "\n"
			rm -f $location/none_shared_workflows.lst
		fi
		
		if [ -s *_workflows.err ] ; then
			cat *_workflows.err >> $errorlog
			echo -e "\n \n "******Error importing few workflows. Please take a look at error log - $errorlog *******"\n \n"
			error_print 1 $error_status "Error importing few workflows..........\n"
		else
			successlog_print "\n Successfully imported all the workflows" "\n"
		fi
	
   fi
   error_status=7
   error_print 0 $error_status
   ;;

 7)

    rm -f $location/invalid_objects.lst
    successlog_print "\n***************************************************************************" "\n"
    successlog_print "\n ...Retrieving Invalid Objects from $environment repository........." "\n"
    msg=`$ORACLE_HOME/bin/sqlplus $rep_db_user/$rep_db_pass@$rep_db_conn_str @$basedir/invalid_workflows.sql $location/invalid_objects.lst`
    RETCODE=$?
    if [ $RETCODE -ne 0 ]
    then
     rm -f $location/invalid_objects.lst
     error_print $RETCODE $error_status "Error while listing invalid objects.." "$msg"
    fi
    if [ -s $location/invalid_objects.lst ]
    then
     successlog_print "There are invalid Objects in $environment repository............" "\n"
     error_status=8
    else
     successlog_print "No invalid objects found in $environment repository............" "\n"
     successlog_print "...............Deployment has been completed successfully in $environment repository............" "\n"
     rm -f $location/invalid_objects.lst
     error_status=10
    fi
    error_print 0 $error_status

  ;;

 8)

   if [ -s $location/invalid_objects.lst ]
   then
    successlog_print "\n**********************************************************************************************\n" "Starting the validation of invalid objects in $environment repository.........\n"
    msg=`pmrep connect -r "$environment"_rep -d $domain_name -n Administrator -x $dom_rep_password`
    RETCODE=$?
    error_print $RETCODE $error_status "Error while connecting to repository...." "$msg"
    error=0
    exec <$location/invalid_objects.lst
    while read invalid_objects;
    do
     object_name=`echo -e $invalid_objects|cut -f1 -d","`
     object_type=`echo -e $invalid_objects|cut -f2 -d","`
     folder=`echo -e $invalid_objects|cut -f3 -d","`
     msg=`pmrep listobjectdependencies -n $object_name -f "$folder" -o $object_type -d mapping,session,workflow -p both -u $location/"$object_name"_dependencies.txt`
     RETCODE=$?
     if [ $RETCODE -ne 0 ]
     then
      errorlog_print "Error Retrieving the object dependencies for $object_name in $folder in $environment." "\n"
      error=`expr $error + 1`
     else
      successlog_print "Retrieving the object dependencies for $object_name in $folder in $environment repository........." "\n"
      successlog_print "$msg" "\n"
     fi
     if [ -s $location/"$object_name"_dependencies.txt ]
     then
      msg=`pmrep validate -i $location/"$object_name"_dependencies.txt -s -p all`
      RETCODE=$?
      if [ $RETCODE -ne 0 ]
      then
       errorlog_print "Error in validating $object_name in $environment." "\n"
       error=`expr $error + 1`
      else
       successlog_print "Starting the validation of $object_name in $folder in $environment repository........." "\n"
       successlog_print "$err_msg" "\n"
      fi
      rm -f $location/"$object_name"_dependencies.txt
     else
      errorlog_print "Object dependencies are not found for $object_name in $folder in $environment." "\n"
     fi
    done
    if [ $error -gt 0 ]
    then
     errorlog_print "Error in validating objects in $environment repository..........\n" "\n"
     rm -f $location/invalid_objects.lst
    else
     rm -f $location/invalid_objects.lst
    fi
   fi

   error_status=9

   error_print 0 $error_status

  ;;

 9)

   rm -f $location/invalid_objects.lst
   msg=`$ORACLE_HOME/bin/sqlplus $rep_db_user/$rep_db_pass@$rep_db_conn_str @$basedir/invalid_objects.sql $location/invalid_objects.lst`
   RETCODE=$?
   if [ $RETCODE -gt 0 ]
   then
    rm -f $location/invalid_objects.lst
    error_print $RETCODE $error_status "Error in retrieving invalid objects from $environment......\n" "$msg"
   fi
   if [ -s $location/invalid_objects.lst ]; then
    successlog_print "\n***************************************************************************" "\n"
    successlog_print "There are still invalid Objects in $environment repository............\n" "Find the invalid objects list below...\n"
    cat $location/invalid_objects.lst >>$logfile
    cat $location/invalid_objects.lst >>$errorlog
    rm -f $location/invalid_objects.lst
   else
    successlog_print "\n***************************************************************************\n" "No invalid objects were found in $environment repository............\n"
    successlog_print "Deployment has been completed successfully in $environment repository............" "\n"
    rm -rf $location/invalid_objects.lst
   fi
  error_status=10

  error_print 0 $error_status

  ;;
 esac
done

rm -f $location/WorkflowsFolder_path.lst
rm -f $errstatus_log
rm -f $location/impcntl.dtd
#rm -rf $install/ETL
rm -f $templog
if [ -s $errorlog ]; then
 echo -e "\n \n"************Deployment has been completed successfully in $environment repository***********""
 echo -e "\n \n "******But there are still invalids in the repository. Please take a look at error log $location/etldeploment_error.log *******"\n \n"
else
 rm -f $errorlog
 echo -e "\n \n"****************Deployment has been completed successfully in $environment repository*************"\n \n"
fi
