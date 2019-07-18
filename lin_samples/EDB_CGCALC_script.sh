#! /bin/ksh

################ERROR HANDLING FOR INSUFFICIENT ARGUMENTS#########################################################
                          
if [ $# != 4 ]                                              #This is To Exit if There are insufficient Input Files
       then
       tput smso
       echo "\nInsufficient Input Arguments mentioned" 
       echo "USAGE:$0 INPUT FILE-HEADER FILE-DETAIL FILE-TRAILER PATH FLG:Check call from ETL command task(Verify Path and Filenames)" 
       echo "\nExample : EDB_CGCALC_script.sh EDB_Cgcalc_Assets_HDR EDB_Cgcalc_Assets EDB_Cgcalc_Assets_TRL PATH"
       tput rmso
       exit 1
fi 
###################################################################################################################

temp_path=$4                                                    #SOURCE PATH VARIABLE 
file_hdr=$1                                                     #HEADER FILE VARIABLE
file_dtl=$2                                                     #DETAIL FILE VARIABLE
file_trl=$3                                                     #TRAILER FILE VARIABLE
      
################ERROR HANDLING FOR NON EXISTING INPUT FILES#######################################################
if [ ! -e $temp_path/$file_hdr ]
  then
    echo "\n$file_hdr header file not found in $temp_path or filename incorrect - Aborting" 
    exit 1
elif [ ! -e $temp_path/$file_dtl ]
  then
   echo "\n$file_dtl detail file not found in $temp_path or filename incorrect - Aborting"
   exit 1
elif [ ! -e $temp_path/$file_trl ]
  then 
   echo "\n$file_trl trailer file not found in $temp_path or filename incorrect - Aborting" 
   exit 1
fi
##################################################################################################################


cat $temp_path/$file_hdr $temp_path/$file_dtl $temp_path/$file_trl > $temp_path/$file_dtl\.out

if [ $? -ne 0 ]
 then
  echo "Problem concatenating $file_hdr , $file_dtl , $file_trl"
  exit 1
fi

exit 0
