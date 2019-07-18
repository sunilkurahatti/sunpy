#! /bin/ksh

##############################Main Program begins here#######################################
#  1. Script us used to Archive the source file to Archive directory
###################################################################################

	
################ERROR HANDLING FOR INSUFFICIENT ARGUMENTS#########################################################
##############Check for # of Input Parameters passed
if [ $# -ne 1 ]
       then
       tput smso
       echo "\nInsufficient Input Arguments mentioned" 
       echo "USAGE:$0 FILE_PATH :Check call from ETL command task(Verify Path and Filenames)" 
       echo "\nExample : Archive.sh FilePath"
       tput rmso
       exit 1
fi 
###################################################################################################################
				
DATETIME=`date +%Y%m%d%H%M%S`
export dirpath=PWX_RESTART_BKP_$DATETIME
mkdir $1/$dirpath
mv $1/*.* $1/$dirpath

















