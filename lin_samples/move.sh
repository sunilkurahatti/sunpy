#! /usr/bin/sh
###################################################################################
#  1. Script us used to create a list file based on the list of file in a specfic 
#     Directory.           
###################################################################################



PRINT=`echo "\nWrong usage...\n"
	echo "The following parameters were received-"
	echo "List file: \t${1:-EMPTY}"
	echo "\nUsage:"
	echo "listfile.sh <List file>"	
       echo "Where"
	echo "List file=file passed as source to ETL"`
	
				

#VALIDATING THE PARAMETERS
if [ $# -lt 1 ]
then
    echo "$PRINT\n"
    exit 1
fi

# MOVING OUTPUT FILES TO THIER CORRESPONDING DIRECTORIES

cd $NAS/currency/BACS
ls BACS.OUT.*.* > $NAS/currency/BACS/temp_BACS.OUT
for i in `cat $NAS/currency/BACS/temp_BACS.OUT`
do
   echo $i
   x=`echo $i | awk -F"." '{print $4}'`
   echo $x
   if [ -f $NAS/currency/BACS/$i ]
   then
      if [ -s $NAS/currency/BACS/$i ]
      then
         mv $NAS/currency/BACS/$i $NAS/currency/BACS/$x
         RETCODE=$?
         if [ $RETCODE -ne 0 ]
         then
            echo "ERROR:Unable move $i file into $x directory"
            exit 1
         fi
      else
         echo " Oooops $i is a zero byte file "
         
      fi
      echo "File $i already moved to corresponding directory"
   fi
done

#CHECK FOR LIST FILE AND MOVING ALL FILES INTO ARCHIVE DIRECTORY
if [ -f $NAS/currency/BACS/NoRecords.out ]
   then
	rm $NAS/currency/BACS/NoRecords.out
	rm $NAS/currency/BACS/$1
   else	
	if [ -f $NAS/currency/BACS/$1 ]
	then
   		cd $NAS/currency/BACS
   		exec < $NAS/currency/BACS/$1
   		while read hdr ; do
     		 d=`date +%m%d%y%H%M%S`
     		 h=`echo "$hdr.$d"`
      		g=`echo "$1.$d"` 
      		if [ -f $NAS/currency/BACS/$hdr ]
      		then
        		 mv $NAS/currency/BACS/$hdr $NAS/currency/archive/monthly/$h
         		RETCODE=$?
         		if [ $RETCODE -ne 0 ]
         		then
            		echo "ERROR:Unable move $hdr file in the list file"
        		exit 1
         		fi
        		gzip $NAS/currency/archive/monthly/$h
         		echo "successfully moved $hdr into archive directory"  
      		else
         		echo "File already moved or does not exist in $NAS/currency/BACS/$hdr"
      		fi
   		done
   		mv $NAS/currency/BACS/$1 $NAS/currency/archive/monthly/$g
   		RETCODE=$?
   		if [ $RETCODE -ne 0 ]
   		then
     		echo "ERROR:Unable to move $l file into archive directory"
      		exit 1
   		fi
   	gzip $NAS/currency/archive/monthly/$g
	else
   	echo "List file already moved to archive folder"
	fi
fi
rm $NAS/currency/BACS/Dummy.out
rm $NAS/currency/BACS/temp_BACS.OUT

















