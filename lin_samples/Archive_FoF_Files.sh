# Script to Archive FoF source and Standard Files
#! /bin/sh
#$1=$$FILE_FRMT_FLG
#$2=$$Archive_Dir
#$3=$$Archive_Src
#$4=$$DATASOURCE_MNEMONIC
#Cmdline - Archive_FoF_Files.sh $1 $2 $3 $4


if [ $# -ne 4 ]
  then
   echo " Wrong Number of arguments passed to Archive_FoF_Files.sh script "
   exit 1
fi


if [ $1 -eq 1 ]
then
## Archive Source files
 
   $PMExtProcDir/archiveetlfiles.sh $3 $2	

	RETCODE=$?
        if [ $RETCODE -ne 0 ]
	then	
	echo "ERROR:Unable to Archive Source Files for $4 "
	 exit 1
	fi

## Move Standard Format files to Input Dir for Archiveing

   mv $PMTargetFileDir/$3 $2/'SF_'$3 

	RETCODE=$?
        if [ $RETCODE -ne 0 ]
	then	
	echo "ERROR:Unable to Move Standard Format Files for $4 "
	 exit 1
	fi

## Archive Standard Format Files

  $PMExtProcDir/archiveetlfiles.sh 'SF_'$3 $2

	RETCODE=$?
        if [ $RETCODE -ne 0 ]
	then	
	echo "ERROR:Unable to Archive Standard Format Files for $4 "
	 exit 1
	fi

   echo "Archive Source and Standard Format Files for $4 - Successful"

else
    
## Move Standard Format files to Input Dir for Archiveing

   mv $PMTargetFileDir/$3 $2/$3 

	RETCODE=$?
        if [ $RETCODE -ne 0 ]
	then	
	echo "ERROR:Unable to Move Standard Format Files for $4 "
	 exit 1
	fi

## Archive Standard Format Files

  $PMExtProcDir/archiveetlfiles.sh $3 $2

	RETCODE=$?
        if [ $RETCODE -ne 0 ]
	then	
	echo "ERROR:Unable to Archive Standard Format Files for $4 "
	 exit 1
	fi
    
   echo "Archive Standard Format Files for $4 - Successful"
   
fi

