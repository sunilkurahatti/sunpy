#!/bin/ksh
##############################Main Program begins here#######################################
#  1. Script us used to Archive the source file to Archive directory
#  2. This Script will Archive the files to $$TargetFile/archive/monthly by default
###################################################################################
if [ $# -lt 2 ] || [ $# -gt 3 ]
	then
	echo "\n Insufficient Input Arguments mentioned" 
	echo "USAGE:$0 FILE_NAME TARGET_FILE_PATH RETENTION_PERIOD:Check call from ETL command task(Verify Path and Filenames)"
	echo "\nExample : Archive.sh OutputFileName/ALL TargetFilePath Retentionperiod"
	exit 1
fi

# MOVING OUTPUT FILES TO THIER CORRESPONDING DIRECTORIES
temp_path=$2
if [ $# -eq 3 ]
then
	retention=$3
else
	retention=monthly
fi

arc_path=$temp_path/archive/$retention
extn=".csv"
file_name=$1
file_name1=$1$extn

################ERROR HANDLING FOR NON EXISTING INPUT FILES##########################
	if [ ! -e $temp_path/$file_name ]
	then
	    echo "\n$3 data file not found or filename incorrect - Aborting" 
	    exit 1
	fi
######################################################################################

        mv $temp_path/$file_name $arc_path/$file_name1
        RETCODE=$?
        if [ $RETCODE -ne 0 ]
        then
                echo "ERROR:Unable to move $file_name file into $temp_path directory"
                exit 1
        fi

