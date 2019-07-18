#! /bin/sh
# Created 08/27/2018 for Feature F21369 PSI 26
# This script will strip the unwanted XML tags to match with the Acord provided XSD
# First argument is the XML File name
# Second argument is an optional argument which would be to delete the input file after successful ETL consumption.
# Output would be parsed XML is the same name as input. The input file would be backed up and deleted if second parameter is passed

echoLog () {

echo -e `date`: $1 >> $2/parseSrcXML.log 

}

exceptHand () {

if [ $1 -ne 0 ] ;
		then 
			echoLog "Error: $2 failed " $3
			if [ $5 -ne 0 ] ;
				then
					rm $(dirname $4)/$(basename $4 .tmp)_tmp*.tmp
					RETCODE=$?

					if [ $RETCODE -ne 0 ] ;
					then 
						echoLog "Removing Temp files inside exception handling failed" $3
					else
						echoLog "Exception Raised - Removed Temp files" $3
					fi	
			fi
			
			mv $(dirname $4)/$(basename $4 .tmp)_bkp.tmp $4
			RETCODE=$?
			
			if [ $RETCODE -ne 0 ] ;
				then 
					echoLog "Moving Contents from backup to actual file inside exception handling failed" $3			
				else
					chmod 777 $4			
					echoLog "Exception Raised - Moving Contents from backup to actual file" $3
				fi	
				
			exit 1
		else
			echoLog "Success: $2 " $3
fi

}

scrptDIR=$(dirname $0)
fileDIR=$(dirname $1)
fileName=$(basename $1)

tmp1=$(dirname $1)/$(basename $1 .tmp)_tmp1.tmp
tmp2=$(dirname $1)/$(basename $1 .tmp)_tmp2.tmp
tmp3=$(dirname $1)/$(basename $1 .tmp)_tmp3.tmp

if [ -f $1 ]
then 
	echoLog "Processing File $1" $scrptDIR
	
	bkp=$fileDIR/$(basename $1 .tmp)_bkp.tmp
	
	cp $1 $bkp
	RETCODE=$?
	exceptHand $RETCODE "Create Back up file" $scrptDIR $1 1

	topPos=`cat $1 | grep -n "<TXLife>"| cut -d ':' -f 1`
	topPos=`expr $topPos + 1`
	
	if [ $topPos -ne 1 ]
	then 
		tail -n +$topPos $1 > $tmp1
			RETCODE=$?
			exceptHand $RETCODE "Remove Top few lines" $scrptDIR $1 1	
			
		botPos=`cat $tmp1 | grep -n "</TXLife>"| cut -d ':' -f 1`

		head -n $botPos $tmp1 > $tmp2
			RETCODE=$?
			exceptHand $RETCODE "Remove Bottom few lines" $scrptDIR $1 1	

			echo '<?xml version="1.0" encoding="UTF-8"?>' > $tmp3
			echo '<TXLife xmlns="http://ACORD.org/Standards/Life/2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://ACORD.org/Standards/Life/2 Acord1203HoldingInquiryRequest.xsd ">' >> $tmp3

		cat $tmp2 >> $tmp3
			RETCODE=$?
			exceptHand $RETCODE "Append Top few lines" $scrptDIR $1 1	
			
		cat $tmp3 > $1
			RETCODE=$?
			exceptHand $RETCODE "Move final file to ETL processing" $scrptDIR $1 1	
			
		chmod 777 $1
		chmod 777 $scrptDIR/parseSrcXML.log
			
		rm -f $tmp1 $tmp2 $tmp3 $bkp
		RETCODE=$?
		exceptHand $RETCODE "Removing Temp files" $scrptDIR $1 1
	else
		echoLog "<TXLife> tag could not be found in the file $1 , Hence skipping the parsing" $scrptDIR
		rm -f $bkp
		RETCODE=$?
		exceptHand $RETCODE "Removing Back up file" $scrptDIR $1 1
		exit 0
fi

else
	echoLog "\n File $1 could not be found " $scrptDIR
	exit 1
fi
