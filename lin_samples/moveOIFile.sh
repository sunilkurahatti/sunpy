#!/bin/sh



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

# MOVING OUTPUT FILES TO THIER CORRESPONDING DIRECTORIES

cd $1
ls $2*.csv > temp_OI.OUT
for i in `cat temp_OI.OUT`
do
   echo $i
   start_position=`echo $i | awk -v find1="_" '{ print (index($i,find1)) }'`
   echo $start_position
   end_position=`echo $i | awk -v find2="_OI_LOADER_" '{ print (index($i,find2)) }'`
   echo $end_position
   strlength1=`expr $start_position + 1`
   echo $strlength1
   strlength2=`expr $end_position - 1`
   echo $strlength2
   #x=`echo $i | awk -F"_" '{print $2}'`
   x=`echo $i | cut -c $strlength1-$strlength2` 
   echo $x
   if [ -f $i ]
   then
      if [ -s $i ]
      then
         \mv $i $x/.
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

\rm temp_OI.OUT
