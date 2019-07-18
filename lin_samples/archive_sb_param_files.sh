# Script to Archive FoF source and Standard Files
#! /bin/sh
#$1=$$stmt_reserve_id
#$2=$$parent_rrd_batch_id
###Cmdline - archive_sb_param_files.sh $1 $2


if [ $# -ne 2 ]
  then
   echo " Wrong Number of arguments passed to archive_sb_param_files.sh script "
   exit 1
fi


mv $PMRootDir/paramfiles/wf_DWS_Statements_SB_$1_$2* $NAS/infodel/archive/monthly

mv $PMRootDir/paramfiles/wf_EDB_Approvals_SB_$1_$2* $NAS/infodel/archive/monthly

RETCODE=$?
        if [ $RETCODE -ne 0 ]
	then	
	echo "ERROR:Unable to Move SB Param file to archive for $1_$2 "
	 exit 1
	fi

