#Script us used to delete zero Byte file
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
if [ ! -s $2/$1 ] 
then
	echo "File Generated has Zero Byte File"
	chmod 777 $2/$1
	rm -f $2/$1
fi
