# Script works only if input file has fields separated by Pipe(|)
#! /bin/sh


if [ $# -lt 2 ] || [ $# -gt 2 ]
  then
   echo " Wrong Sytax .. Usage : $0 Batch_File_Name "
   exit 1
fi

	batchfilename=$1
	cd `dirname $1`
	rm -f $2
	RETCODE=$?
       	  if [ $RETCODE -ne 0 ]
	        	 then	
	        	    echo "ERROR:Unable to Remove Old File. "
	         	  exit 1
	         fi
	sort -t "|" -k 2,2n $1 | awk -F"|" '{print $1}' > $2
			RETCODE=$?
       	  		 if [ $RETCODE -ne 0 ]
	        		 then	
	        		    echo "ERROR:Unable to Sort And Create File. "
	         		    exit 1
	        	 	fi
		

