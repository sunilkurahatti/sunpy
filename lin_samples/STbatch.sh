# Script works only if input file has fields separated by Pipe(|)
#! /usr/bin/sh


if [ $# -lt 8 ] || [ $# -gt 9 ]
  then
   echo " Wrong Sytax .. Usage : $0 Batch_File_Name "
   exit 1
fi

if [ $8 -eq 0 ]
then
	if [ `find $7 -name "*.$3" -type f -print | wc -l` -gt 0 ] ; 
	then    
	#Concating all Files

		batchfilename=$1
		cd `dirname $1`

		cat *.$3 > $batchfilename
		RETCODE=$?
       	  	 if [ $RETCODE -ne 0 ]
	        		 then	
	        		    echo "ERROR:Unable to Concat all Schedule Files. "
	         		    exit 1
	        	 fi

		#Padding Firm_Id with Zeros 

		if [ $2 -eq $6 -o $2 -eq 1002 ] && [ $4 = "STMT" ]
		then
			firm_id=$2
		else
			firm_id=`echo $2 | awk '{printf "%07d\n",$1}'`
		
		fi

		batchfilename=$1
		cd `dirname $1`
		/usr/xpg4/bin/awk -F"~" '{print $1}' $batchfilename | sort -u -T `pwd` >/var/tmp/batch.temp.$$ 2>$9
		for i in `cat /var/tmp/batch.temp.$$`
		do
			grep "^`echo $i | awk '{printf "%-8s\n",$0}'`" $batchfilename | sort -t"~" -k 3 -T `pwd` 2>> $9 | /usr/xpg4/bin/awk -F"~" '{print $1 $2 $4 }' > SI.T.F$firm_id.${i}.$4.SLA$5.INPUT &
			RETCODE=$?
       	  		 if [ $RETCODE -ne 0 ]
	        		 then	
	        		    echo "ERROR:Unable to Sort And Create File. "
	         		    exit 1
	        	 fi
			done
			wait
		rm /var/tmp/batch.temp.$$
		rm -f *.$3
		if [ -f "$3.err" ] && [ ! -s "$3.err" ]
		then
  			rm -f $3.err
		fi
		echo "Successfully Sorted and Created Outbound File for $3. "
		#rm Dummy.out
	else
	batchfilename=$1
	#Creating an Empty File for not to fail Statements Batch ETL for 534.
	cd `dirname $1`
		if [ $2 -eq $6 -o $2 -eq 1002 ] && [ $4 = "STMT" ]
		then
			echo " " > SI.T.F$2.$3.$4.SLA$5.INPUT
		fi
	
	fi
	
else
#Script For Batch ETL.
	#If File is Created for the Batch
	if test -s $1
	then
	batchfilename=$1
	firm_id=`echo $2 | awk '{printf "%07d\n",$1}'`

	cd `dirname $1`
	cat $1 > SI.T.F$firm_id.${3}.$4.SLA$5.INPUT
	 RETCODE=$?
       	  if [ $RETCODE -ne 0 ]
	         then
	            echo "ERROR:Unable to create 534 Outbound file "
	            exit 1
       	  fi
	#Removing the Old count from 6.0 File and placing Count of records in 534 File
	filename=SI.T.F$firm_id.${3}.$4.SLA$5.INPUT
	count=`wc -l $filename | awk '{ print $1 }'`
	#count=`expr ${count} - 2`
	count=`echo $count | awk '{printf "%09d\n",$1}'`
	# Replaces {*count*} with Record Count
	perl -p -i -e 's/\{\*count\*\}/'$count'/g' $filename
	 RETCODE=$?
       	  if [ $RETCODE -ne 0 ]
	         then	
	            echo "ERROR:Unable Replace the New Count to 534 Outbound file "
	            exit 1
	         fi
	rm -f *.$3
	#rm Dummy.out
	echo "Successfully Created 5.3.4 Outbound File for $3. "
	fi

fi


