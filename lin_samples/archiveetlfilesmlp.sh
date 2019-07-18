#! /bin/ksh


####################Function to archive files#####################################
Archive_Files()
{
################ERROR HANDLING FOR NON EXISTING INPUT FILES##########################
	if [ ! -e $1/$3 ]
	then
	    echo "\n$3 data file not found or filename incorrect - Aborting" 
	    exit 1
	fi
######################################################################################
	mv $1/$3 $2/$3
	RETCODE=$?
	if [ $RETCODE -ne 0 ]
	then
		echo "ERROR:Unable to move $file_name file into $temp_path directory"
	    	exit 1
	fi
	#ZIP THE FILE
	cd $2
	file_append=`echo $3 | awk -F. '{print $1}'`_`date '+%m%d%y_%H%M%S'`
	#file_append=$3_`date '+%m%d%y_%H%M%S'`
	zip "$file_append" $3 
	RET_CODE=$?
	if [ $RETCODE -ne 0 ]
	then
		echo "ERROR:Unable to Zip $file_name"
	    	exit 1
	else
	#REMOVE THE OLD FILE
	rm $2/$3
		if [ $RETCODE -ne 0 ]
		then
			echo "ERROR:Unable to Delete $file_name"
	    		exit 1
		fi
	fi 
	
}

##############################Main Program begins here#######################################
#  1. Script us used to Archive the source file to Archive directory
#  2. This Script will Archive the files to $$TargetFile/archive/monthly by default
###################################################################################

	
################ERROR HANDLING FOR INSUFFICIENT ARGUMENTS#########################################################
##############Check for # of Input Parameters passed
if [ $# -lt 2 ] || [ $# -gt 3 ]                                               
       then
       tput smso
       echo "\nInsufficient Input Arguments mentioned" 
       echo "USAGE:$0 FILE_NAME TARGET_FILE_PATH RETENTION_PERIOD:Check call from ETL command task(Verify Path and Filenames)" 
       echo "\nExample : Archive.sh OutputFileName/ALL TargetFilePath Retentionperiod"
       tput rmso
       exit 1
fi 
###################################################################################################################
				

# MOVING OUTPUT FILES TO THIER CORRESPONDING DIRECTORIES

temp_path=$2
if [ $# -eq 3 ]
then
	retention=$3
else
	retention=yearly
fi

arc_path=$temp_path/archive/$retention

if test $1 = ALL 
then
	ls $temp_path|while read file_name
	do
		if [ ! -d $temp_path/"$file_name" ]; then
			Archive_Files $temp_path $arc_path "$file_name"
		fi
	done
else

	file_name=$1
	Archive_Files $temp_path $arc_path $file_name

fi
