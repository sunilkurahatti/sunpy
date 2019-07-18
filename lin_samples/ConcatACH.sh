#Script us used to create a list file based on the list of file in a specfic 
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

if [ -d $NAS/currency ]
then
     echo "Currency directory exists"
     
    # remove old list file if any
       if [ -f $NAS/currency/$1 ]
       then
         rm -f $NAS/currency/$1
          RETCODE=$?
          if [ $RETCODE -ne 0 ]
          then
             echo "ERROR:Unable to delete old $1 list file"
             exit 1
          fi
       fi

    #add all ach.* file names into list file   
 if  [ `ls $NAS/currency/$1_* | wc -l` -ne 0 ] 
        then
          cd $NAS/currency/
          find $1_* > $NAS/currency/$1 
          echo "Successfully created the list file"
        fi      

    echo "Successfully Appended the File Name to files"
else
   echo "ERROR:Currency directory does not exists"
   exit 1
fi
