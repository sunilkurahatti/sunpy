# Script to create the outbound file for RRD
#!/bin/sh


if [ $# -lt 8 ] || [ $# -gt 9 ]
  then
   echo " Wrong Sytax .. Usage : $0 Batch_File_Name "
   exit 1
fi

firm_id=`echo $2 | awk '{printf "%07d\n",$1}'`

if [ $9 = "RRD" ]
then

batch_filename='SI.T.F'$firm_id'.'${3}'.'$4'.SLA'$5'.INPUT'
 

elif [ $9 = "SRD" ]
then

batch_filename='SIST.F'$firm_id'.'${3}'.'$4'.SLA'$5'.INPUT'
 

else 
   echo " Wrong File Destination : $9 "
   exit 1

fi


if [ $7 -eq 0 ]
then
	if [ `find $6 -name "*.$3" -type f -print | wc -l` -gt 0 ] ; 
	then    
	#Concating all Files
          echo "contatinating files"
		
		cd `dirname $1`

	        echo 'batch file name is ' ${batch_filename}
		cat *.$3 > $batch_filename
			RETCODE=$?
       	  	 if [ $RETCODE -ne 0 ]
	            then	
	            echo "ERROR:Unable to Concat all Schedule Files. "
	            exit 1
	         fi
		
	fi

fi

rm $6/*.$3
	
exit 0




