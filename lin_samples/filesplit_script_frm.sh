#! /bin/sh
###########################################################################################################
# 1.Remove new line Feed from corresponding file created by each ETL instances.         
###########################################################################################################

if [ $# -lt 3 ] || [ $# -gt 3 ]
  then
   echo " Wrong Sytax .. Usage : fileLocation firm_id "
   exit 1
fi
cd $1
for f in *_$3_*$2
do  
  tr -d '\n' <$f > pan_$f
  rm -f $f
  if [ -f pan_$f ]   
  then 
    mv pan_$f  $f
  fi
done

