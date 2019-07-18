  
###################################################################################

#!/bin/sh 
#echo 'execution started'

cat $1 $2  > $3

RETCODE=$?
 if [ $RETCODE -ne 0 ]
 then  echo "ERROR:Unable to Concat all qualified security fiels "
  exit 1
  fi

