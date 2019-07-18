# Script works only if input file has fields separated by Pipe(|) unix formated now
#! /bin/sh

DIR=${1}/
FILE=$2
BATCH=$3
BATCHDATE=$(echo $FILE | cut -c 29-36)
FILESUFFEX=$(echo $FILE | cut -d '_' -f 2-| sed 's/Cash/CASH-RECEIPT/')

echo $DIR
echo $FILE
echo $BATCH
echo $BATCHDATE
echo $FILESUFFEX

#awk -F '|' ' FNR >1  {print "000" substr("ALL_RBPS_Cash_V1_SILDR_LUMS_20180410_140003.csv",29,8) "                    " substr("ALL_RBPS_Cash_V1_SILDR_LUMS_20180410_140003.csv",29,8) "                                                                                000           "> "/nas/gwmt3/batch/i08/ft/"$1substr("ALL_RBPS_Cash_V1_SILDR_LUMS_20180410_140003.csv",4) ; printf "%-30s %-23s %-49s %-13s %-14s\n", "330    " $2, substr("ALL_RBPS_Cash_V1_SILDR_LUMS_20180410_140003.csv",29,8),$3 ,$4,$5 > "/nas/gwmt3/batch/i08/ft/"$1substr("ALL_RBPS_Cash_V1_SILDR_LUMS_20180410_140003.csv",4) ;   print $1substr("ALL_RBPS_Cash_V1_SILDR_LUMS_20180410_140003.csv",4) } ' /nas/gwmt3/batch/i08/ft/ALL_RBPS_Cash_V1_SILDR_LUMS_20180410_140003.csv | sort -u > /nas/gwmt3/batch/i08/ft/tmpp.txt                                                                            
#awk  -F '|' ' FNR >1  {print "000" '$BATCHDATE' "                    " '$BATCHDATE' "                                                                                000           "  > "'$DIR'tmppp.txt" } '  $DIR$FILE  
#cat /nas/gwmt3/batch/i08/ft/ALL_RBPS_Cash_V1_SILDR_LUMS_20180409_140012.csv | /usr/bin/gawk  -F '|' ' FNR >1  {print "000" BD "                    " BD "                                                                                000           " > DIR$1"_"SUF   }'  BD=${BATCHDATE} FD=${FILE} DIR=${DIR} SUF=${FILESUFFEX} 

cat ${DIR}${FILE} | /usr/bin/gawk  -F '|' ' FNR >1  {print "000" BD "                    " BD "                                                                                000           " > DIR$1"_"SUF ;printf "%-30s %-23s %-49s %-13s %-14s\n", "330    " $2, BD,$3 ,$4,$5 > DIR$1"_"SUF ;print $1"_"SUF }'  BD=${BATCHDATE} FD=${FILE} DIR=${DIR} SUF=${FILESUFFEX} | sort -u > $DIR"CI_Generic_Controlfile_"$BATCH".out"  

RETCODE=$?
       	  		 if [ $RETCODE -ne 0 ]
	        		 then	
	        		    echo "ERROR:Problem 2:Unable to Sort And Create File. "
	         		    exit 1
	        	 	fi
