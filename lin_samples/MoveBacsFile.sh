#! /bin/sh
###################################################################################
#  1. Script us used to create a list file based on the list of file in a specfic 
#     Directory.           
###################################################################################



PRINT=`echo "\nWrong usage...\n"
        echo "The following parameters were received-"
        echo "List file: \t${1:-EMPTY}"
        echo "\nUsage:"
        echo "MoveBacsFile.sh <List file> <File Name>"
       echo "Where"
        echo "List file=file passed as source to ETL"
  echo "File Name=file passed as source to ETL"`

#VALIDATING THE PARAMETERS
if [ $# -lt 2 ]
then
    echo "$PRINT\n"
    exit 1
fi

#CHECK FOR LIST FILE AND MOVING ALL FILES INTO ARCHIVE DIRECTORY
if [ -f $NAS/currency/BACS/$1 ]
then
	cd $NAS/currency/BACS
	exec < $NAS/currency/BACS/$1
	while read hdr ; do
     		 d=`date +%m%d%y%H%M%S`
     		 h=`echo "$hdr.$d"`
#move the files within listfile into archive directory
      		if [ -f $NAS/currency/BACS/$hdr ]
      		then
	        		 mv $NAS/currency/BACS/$hdr $NAS/currency/archive/monthly/$h
         			RETCODE=$?
         			if [ $RETCODE -ne 0 ]
         			then
            			echo "ERROR:Unable move $hdr file in the list file"
        			exit 1
         			fi
		fi
        		gzip $NAS/currency/archive/monthly/$h
         		echo "successfully moved $hdr into archive directory"  
	done
#move the listfile into archive directory
	g=`echo "$1.$d"` 
	mv $NAS/currency/BACS/$1 $NAS/currency/archive/monthly/$g
	gzip $NAS/currency/archive/monthly/$g

fi

#CHECK FOR I/P FILE AND MOVING   INTO ARCHIVE DIRECTORY
    if [ -f $NAS/currency/BACS/$2 ]
        then
      cd $NAS/currency/BACS
      d=`date +%m%d%y%H%M%S`
            g=`echo "$2.$d"`
                mv $NAS/currency/BACS/$2 $NAS/currency/archive/monthly/$g
                RETCODE=$?
                if [ $RETCODE -ne 0 ]
                then
                echo "ERROR:Unable to move $l file into archive directory"
                exit 1
                fi
          gzip $NAS/currency/archive/monthly/$g
        fi


# MOVING OUTPUT FILES TO THIER CORRESPONDING DIRECTORIES

cd $NAS/currency/BACS
ls BACS.OUT.* > $NAS/currency/BACS/temp_BACS.OUT
for i in `cat $NAS/currency/BACS/temp_BACS.OUT`
do
   echo $i
   x=`echo $i | awk -F"." '{print $3}'`
   echo $x
   if [ -f $NAS/currency/BACS/$i ]
   then
        d=`date +%m%d%y%H%M%S`
         m=`echo "$i.$d"`
         cp $NAS/currency/BACS/$i $NAS/currency/archive/monthly/$m
   echo $m   
   if [ -s $NAS/currency/BACS/$i ]
      then
         mv $NAS/currency/BACS/$i $NAS/currency/BACS/$x/$m
         RETCODE=$?
         if [ $RETCODE -ne 0 ]
         then
            echo "ERROR:Unable move $i file into $x directory"
            exit 1
         fi
      else
         echo " Oooops $i is a zero byte file "

      fi
      echo "File $i moved to corresponding directory"
   fi
done


rm $NAS/currency/BACS/Dummy.out
rm $NAS/currency/BACS/temp_BACS.OUT
