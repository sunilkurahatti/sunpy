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
if [ $# -lt 2 ]
then
    echo "$PRINT\n"
    exit 1
fi

# MOVING INPUT FILES ARCHIVE FOLDER

cd $2

for i in `cat $2/$1`
do
   echo $i
   x=`echo $i | /bin/awk -F"." '{print $4}'`
   echo $x
   if [ -f $2/$i ]
   then
      if [ -s $2/$i ]
      then
	 #CALLING archiveetlfiles SCRIPT
	 k=`$PMExtProcDir/archiveetlfiles.sh  $i  $2`
	 RETCODE=$?
	 if [ $RETCODE -eq 0 ]
	 then
	   echo "successfully invoked archiveetlfiles SCRIPT"
	 else
	   echo "$k"
	   exit 1
	 fi
      else
         echo " Oooops $i is a zero byte file "
         
      fi
      echo "File $i already moved to corresponding directory"
   fi
done



