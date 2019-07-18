 #! /bin/sh
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

if [ -d $NAS/currency/BACS ]
then
   echo "BACS directory exists"
   if [ -f $NAS/currency/BACS/$1 ]
   then
      rm -f $NAS/currency/BACS/$1
      RETCODE=$?
      if [ $RETCODE -ne 0 ]
      then
         echo "ERROR:Unable to delete old $1 list file"
         exit 1
      fi
    fi
    cd $NAS/currency/BACS
    for i in `ls BACS.OUT.*.*`
    do
        if [ -f $NAS/currency/BACS/$i ]
        then
           rm -f $NAS/currency/BACS/$i
           RETCODE=$?
           if [ $RETCODE -ne 0 ]
           then
              echo "ERROR:Unable to delete old $i files"
              exit 1
           fi
        fi
    done    
    cd $NAS/currency/BACS
    touch $NAS/currency/BACS/$1
    RETCODE=$?
    if [ $RETCODE -ne 0 ]
    then
       echo "ERROR:Unable to create list file"
       exit 1
    fi  
    
    $PMExtProcDir/find_olderfiles.sh > $NAS/currency/BACS/$1
    
    echo "Successfully created the list file"
	cd $NAS/currency/BACS
	if test -s $1
	then
		echo "List File is not Empty"
	else
		rm -f $NAS/currency/BACS/$1
     		echo "ERROR:Unable to find entry into list file means no files to process"
		echo "NoRecords.out"  >> $NAS/currency/BACS/$1
		echo " " > NoRecords.out
		RETCODE=$?
     		 if [ $RETCODE -ne 0 ]
     		 then
       		  echo "ERROR:Unable to delete old $1 list file - test no records"
       		  
    		 fi

       fi
 #Appending File Name to the Files
    cd $NAS/currency/BACS
    for i in `awk '{print}' $NAS/currency/BACS/$1`
    do  
       filename=$i
     if [ "$filename" = "NoRecords.out" ]
     then
	echo " ERROR: No file to process"
     else 
       echo >> ${filename}    # Appending blank lines as sometimes we get last line without New line Char
	sed '/^$/d' $i|sed "s;^;${filename}|;g"  >> temp.out   # Removing Blank lines as they are not needed
       RETCODE=$?
         if [ $RETCODE -ne 0 ]
         then
            echo "ERROR:Unable to Append File Name "
            exit 1
         fi
	mv temp.out $filename
	RETCODE=$?
         if [ $RETCODE -ne 0 ]
         then
            echo "ERROR:Unable to Create Outbound File with Appended FileName "
            exit 1
         fi
     fi 
    done
    echo "Successfully Appended the File Name to files"
		
else
   echo "ERROR:Currency directory does not exists"
   exit 1
fi
