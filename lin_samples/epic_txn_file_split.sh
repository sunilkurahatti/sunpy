# Script works only if input file has fields separated by Pipe(|)
#! /bin/sh

cd $2
filename=$1
filename1=`echo $1 | sed 's/\(.*\)\..*/\1/'`
echo $filename1

mm=`echo "$3" | awk '{print substr($0,5,2)}'`
echo $mm

dd=`echo "$3" | awk '{print substr($0,7,2)}'`
echo $dd

yyyy=`echo "$3" | awk '{print substr($0,1,4)}'`
echo $yyyy

/bin/awk '!/^$/{
a=substr($0,0,index($0,"|")-1)

print substr($0,index($0,"|")+1) > "'$filename1'""_"'a'"_""'$yyyy'""'$mm'""'$dd'"".txt"}' $filename 

RETCODE=$?
         if [ $RETCODE -ne 0 ]
         then
            echo "ERROR:Unable to Split the file "
            exit 1
         fi


	


