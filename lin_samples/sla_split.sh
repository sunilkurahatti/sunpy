# Script works only if input file has fields separated by Pipe(|)
#! /bin/sh

cd $2
filename=$1
filename1=`echo $1 | sed 's/\(.*\)\..*/\1/'`
#filename2=`echo "$filename" | cut -d'.' -f1`
bdate=$3
/bin/awk '!/^$/{
a=substr($0,0,index($0,"|")-1)
print substr($0,index($0,"|")+1) > a"'_$filename1'""'_$bdate'.dat"}' $filename
RETCODE=$?
         if [ $RETCODE -ne 0 ]
         then
            echo "ERROR:Unable to Split the file "
            exit 1
         fi

