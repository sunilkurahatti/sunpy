#! /bin/ksh

# This function will create a .csv file using header & detail file and removes the header file
Append_Files()
{
		cat $2/$1_HDR $temp_path/$1 > $temp_path/$1.csv
#		\rm $2/$1 $2/$1_HDR
		rm -f $2/$1 $2/$1_HDR
		if [ $? -ne 0 ]
		then
		  echo "Problem concatenating $1_HDR , $1 "
		  exit 1
		fi
}

####Main Program starts here
################ERROR HANDLING FOR INSUFFICIENT ARGUMENTS#########################################################
                          
if [ $# != 2 ]                                               #This is To Exit if There are insufficient Input Files
       then
       tput smso
       echo "\nInsufficient Input Arguments mentioned" 
       echo "USAGE:$0 OUTPUT_FILENAME OUTPUT_FILEPATH :Check call from ETL command task(Verify Path and Filenames)" 
       echo "\nExample : EDB_INTERESTPOSTING.sh $OutputFileName $$TargetFilePath"
       tput rmso
       exit 1
fi 
###################################################################################################################


temp_path=$2                                                    #SOURCE PATH VARIABLE 

      
################ERROR HANDLING FOR NON EXISTING INPUT FILES##########################
file_exists=$1
if [ ! -e $temp_path/$file_exists ]					
then
    echo "\n$file_exists data file not found or filename incorrect - Aborting" 
    exit 1
else
	file_exists=$1_HDR
	if [ ! -e $temp_path/$file_exists ]
	then 
		echo "\n$file_exists header file not found or filename incorrect - Aborting" 
		exit 1
	fi
fi
######################################################################################
if [ -s $temp_path/$1 ]				#Checks whether file exists and size greater than zero or not
then
	if [ -e $temp_path/$1.csv ]		
	then
		\rm $temp_path/$1.csv
		Append_Files $1 $temp_path
	else
		Append_Files $1 $temp_path
	fi
else
	echo "\n$1 is a Zero byte file"
#	\rm $temp_path/$1 $temp_path/$1_HDR
	rm -f $temp_path/$1 $temp_path/$1_HDR
fi
exit 0
