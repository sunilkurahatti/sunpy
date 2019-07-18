#! /bin/sh
###################################################################################
#  1. Script us used to remove blank line from a file
###################################################################################

PRINT=`echo "\nWrong usage...\n"
        echo "The following parameters were received-"
        echo "OutputFile: \t${1:-EMPTY}"
        echo "\nUsage:"
        echo "RemoveBlankLines <comp> <File Name>"
        echo "Where"
        echo "File Name=file passed as source to ETL"`


#VALIDATING THE PARAMETERS
if [ $# -lt 2 ]
then
    echo "$PRINT\n"
    exit 1
fi

if [ -d $NAS/$1 ]
then
  echo "Altus directory exists"

# check if file exists and remove blank lines
   if [ -f $NAS/$1/$2 ]
   then
      echo "File exists in Altus directory"
#      sed 's/$/\^M/' $NAS/$1/$2 > $NAS/$1/tempresp1.out
#      sed '$ s/\^M//' $NAS/$1/tempresp1.out > $NAS/$1/tempresp2.out
#      sed '/^*$/d' $NAS/$1/tempresp2.out > $NAS/$1/$2
#      sed -i '$d' $NAS/$1/tempresp2.out > $NAS/$1/$2
else
      echo "File doesnt exists in Altus directory"
   fi
fi

#rm $NAS/$1/tempresp1.out
#rm $NAS/$1/tempresp2.out