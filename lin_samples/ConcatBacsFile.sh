 #! /bin/sh
###################################################################################
#  1. Script us used to create a list file based on the list of file in a specfic 
#     Directory.           
###################################################################################



PRINT=`echo "\nWrong usage...\n"
	echo "The following parameters were received-"
	echo "List file: \t${1:-EMPTY}"
	echo "\nUsage:"
	echo "listfile.sh <List file> <File Name>"	
       echo "Where"
	echo "List file=file passed as source to ETL"
  echo "File Name=file passed as source to ETL"`
	
#VALIDATING THE PARAMETERS
if [ $# -lt 2 ]
then
    echo "$PRINT\n"
    exit 1
fi

if [ -d $NAS/currency/BACS ]
then
   echo "BACS directory exists"

# remove old list file if any
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

# remove old BACS.out file if any    
   if [ -f $NAS/currency/BACS/$2 ] 
   then
      rm -f $NAS/currency/BACS/$2
      RETCODE=$?
      if [ $RETCODE -ne 0 ]
      then
         echo "ERROR:Unable to delete old BACS.out file"
         exit 1
      fi
   fi

#create a list file    
    cd $NAS/currency/BACS
    touch $NAS/currency/BACS/$1
    RETCODE=$?
    if [ $RETCODE -ne 0 ]
    then
       echo "ERROR:Unable to create list file"
       exit 1
    fi  
    
#add all bacs.out.* file names into list file
    if  [ `ls $NAS/currency/BACS/BACS.OUT.* | wc -l` -ne 0 ] 
    then
      cd $NAS/currency/BACS
      find BACS.OUT.* > $NAS/currency/BACS/$1 
      echo "Successfully created the list file"
    fi

#sleep 15
#check whether list files are empty    
	cd $NAS/currency/BACS
	if test -s $1
	then
		echo "List File is not Empty"
		
#Concat multiple files into single file with the file name passed in input parameter		
		for i in `awk '{print}' $NAS/currency/BACS/$1`
    do 
      if [ -f $i ]
      then
        echo >> ${i} # Appending blank lines as sometimes we get last line without New line Char
        sed '/^$/d' $i | cat "$i" >> $2 # Removing Blank lines as they are not needed
	    fi 
    done
    
#Appending File Name to the Files
    filename=$2
    sed '/^$/d' $2|sed "s;^;${filename}|;g"  >> temp.out
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
      echo "Successfully Appended the File Name to files"
	else
    echo "BACS.OUT" > $NAS/currency/BACS/$1	
    echo " " > BACS.OUT
  fi
else
   echo "ERROR:Currency directory does not exists"
   exit 1
fi
