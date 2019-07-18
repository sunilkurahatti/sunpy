# Script works only if input file has fields separated by Pipe(|)
#! /bin/sh

echo "Starting"
cd $4
filename1=`echo $1 | sed 's/\(.*\)\..*/\1/'`
filename2=`echo $2 | sed 's/\(.*\)\..*/\1/'`
filename3=`echo $3 | sed 's/\(.*\)\..*/\1/'`
bdate=$5

if [ -s $4/slakpi_all.txt ];
then
var=`cat slakpi_all.txt`
for i in $var; do
echo "Creating Zero byte file"
 rm -f $4/${i}_${filename1}_$bdate.dat
 rm -f $4/${i}_${filename2}_$bdate.dat
 rm -f $4/${i}_${filename3}_$bdate.dat
 touch $4/${i}_${filename1}_$bdate.dat
 touch $4/${i}_${filename2}_$bdate.dat
 touch $4/${i}_${filename3}_$bdate.dat

done
fi

if [ -s $4/slakpi_nodetail.txt ];
then
var=`cat slakpi_nodetail.txt`
for i in $var; do
	echo "Creating Zero byte File"
	touch $4/${i}_${filename1}_$bdate.dat
	touch $4/${i}_${filename3}_$bdate.dat
	done
fi

if [ -s $4/slakpi_rev.txt ];
then 
  var=`cat slakpi_rev.txt`
  for i in $var;   do
  echo "Creating Zero byte File"
  touch $4/${i}_${filename1}_$bdate.dat
  done
fi


if [ -s $4/slakpi_det.txt ];
then 
  var=`cat slakpi_det.txt`
  for i in $var;   do
  echo "Creating Zero byte File"
  touch $4/${i}_${filename3}_$bdate.dat
   done
fi




