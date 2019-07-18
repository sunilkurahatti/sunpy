#!/bin/sh

error_print()
{
  if [ $1 -gt 0 ]
  then
   echo "Failed"
   echo "error_status=$2" > $errstatus_log
   echo "Error:$3" >> $logfile
   echo "\n$msg" >> $logfile
   echo "\n$3"
   echo $msg
   echo "Please refer log file $logfile"
   echo "Exit 1"
   exit 1
  else
   echo "error_status=$2">$errstatus_log
  fi
}

if [ -z "$INFA_HOME" ];then 
   echo "\$INFA_HOME is not defined.....\n" 
   echo "exit 1"
   exit 1
else
   install=$INFA_HOME/install
   ETL_HOME=$INFA_HOME/server/infa_shared

fi

if [ -s $INFA_HOME/etlenvbuild.cfg ]; then
   . $INFA_HOME/etlenvbuild.cfg
else
   echo "etlenvbuild.cfg is not present in $INFA_HOME..."
   echo "exit 1"
   exit 1
fi

if [ -s $INFA_HOME/etldeployment.cfg ]; then
   . $INFA_HOME/etldeployment.cfg
else
   echo "etldeployment.cfg is not present in $INFA_HOME..."
   echo "exit 1"
   exit 1
fi
location=$1
logfile=$location/etldeployment.log
errstatus_log=$location/etldeployment_errstatus.log
basedir=$PMExtProcDir

if [ -s $errstatus_log ]; then
 error_status=`awk 'BEGIN{FS="="}/error_status/ {print $2}' $errstatus_log`
else
 error_status=4
fi

if cat $location/FilesFolder_path.lst|grep -w 'reg'>/dev/null
then
  if [ ! -s $location/ETL/infa-etl/Build/extractmap.ini ]; then
    error_print 1 $error_status "extractmap.ini template was not checked out"
  fi
  if [ ! -s $PWX_HOME/reg/CCT.dat ] || [ ! -s $PWX_HOME/reg/CCT.idx ]; then
    error_print 1 $error_status "CCT files were not copied to $PWX_HOME/reg folder" "..."
  fi
  if [ ! -d $PWX_HOME/extmaps ] ; then
    error_print 1 $error_status "Error:$PWX_HOME/extmaps folder does not exist....\n"
  fi 
  echo "\n Starting the generation of extract maps for $environment environment......\n">>$logfile
  cat $location/ETL/infa-etl/Build/extractmap.ini|sed "-e s/\$streamsl1/$streamsl1_db_instance/g"|sed "-e s/\$schema/$streamsl1_db_schema/g">$location/extractmap_$extmap.ini
      	 
  RETCODE=$?
      
  if [ RETCODE -ne 0 ]; then
    rm -f $location/extractmap_$extmap.ini
    error_print $RETCODE $error_status "Error in generating extractmap.ini \n" 
  fi
  msg=`$PWX_HOME/dtlurdmo $location/extractmap_$extmap.ini`
  RETCODE=$?
  if [ RETCODE -ne 0 ]; then
   rm -f $location/extractmap_$extmap.ini
   error_print $RETCODE $error_status "Error in generating generating extract maps for $streamsl1_db_instanc schema \n" "$msg"
  fi
  rm -f $location/extractmap_$extmap.ini
     
  echo "\n All the extract maps are successfully generated for $environment environment......\n">>$logfile

fi
