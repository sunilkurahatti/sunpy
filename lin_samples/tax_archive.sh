
###################################################################################
#  1. Script us used to archive file with input file path and substring of file name
###################################################################################

	
# Dir File_Name				

#VALIDATING THE PARAMETERS
if [ $# -lt 2 ]
then
    echo "$PRINT\n"
    exit 1
fi

cd $1
> $1/temp_$2.OUT
ls $2*.* >> $1/temp_$2.OUT
# Added By BChekuri to get the file name with small letters | 12-Mar-2014 | Start
ls `echo $2 | tr '[A-Z]' '[a-z]'`*.* >> $1/temp_$2.OUT
# Added By BChekuri to get the file name with small letters | 12-Mar-2014 | End

	if [ -f $1/temp_$2.OUT ]
	then
   		cd $1
   		exec < $1/temp_$2.OUT
   		while read hdr ; do
     		 d=`date +%m%d%y%H%M%S`
     		 h=`echo "$hdr.$d"`
      		g=`echo "$1.$d"` 
      		if [ -f $1/$hdr ]
      		then
        		 mv $1/$hdr $1/archive/monthly/$h
         		RETCODE=$?
         		if [ $RETCODE -ne 0 ]
         		then
            		echo "ERROR:Unable move $hdr file in the list file"
        		exit 1
         		fi
        		gzip $1/archive/monthly/$h
         		echo "successfully moved $hdr into archive directory"  
      		else
         		echo "File already moved or does not exist in $1/$hdr"
      		fi
   		done
   		rm -f temp_$2.OUT
   		RETCODE=$?
   		if [ $RETCODE -ne 0 ]
   		then
     		echo "ERROR:Unable to remove temp file"
      		exit 1
   		fi
   	
fi